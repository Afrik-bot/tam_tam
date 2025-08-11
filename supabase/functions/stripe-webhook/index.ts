import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.21.0';
import Stripe from 'https://esm.sh/stripe@12.0.0?target=deno';

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};

serve(async (req) => {
    // Handle CORS preflight request
    if (req.method === 'OPTIONS') {
        return new Response('ok', {
            headers: corsHeaders
        });
    }

    try {
        // Create a Supabase client
        const supabaseUrl = Deno.env.get('SUPABASE_URL');
        const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY');
        const supabase = createClient(supabaseUrl, supabaseKey);

        // Create a Stripe client
        const stripeKey = Deno.env.get('STRIPE_SECRET_KEY');
        const stripe = new Stripe(stripeKey);

        const signature = req.headers.get('stripe-signature');
        const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET');
        const body = await req.text();

        let event;
        try {
            event = stripe.webhooks.constructEvent(body, signature!, webhookSecret!);
        } catch (err) {
            console.error('Webhook signature verification failed:', err);
            return new Response('Webhook signature verification failed', { status: 400 });
        }

        // Handle the checkout.session.completed event
        if (event.type === 'checkout.session.completed') {
            const session = event.data.object;
            
            // Update payment status in database
            await supabase
                .from('stripe_payments')
                .update({ 
                    status: 'completed',
                    updated_at: new Date().toISOString()
                })
                .eq('stripe_payment_intent_id', session.payment_intent);

            // Process TamTam wallet transaction if applicable
            const metadata = session.metadata;
            if (metadata?.transaction_type === 'wallet_deposit') {
                const userId = metadata.user_id;
                const amount = parseFloat(metadata.amount);
                const currency = metadata.currency || 'usd';

                // Update user wallet balance
                if (currency === 'usd') {
                    await supabase.rpc('increment', {
                        table_name: 'wallets',
                        row_id: userId,
                        column_name: 'usd_balance',
                        x: amount
                    });
                } else if (currency === 'eur') {
                    await supabase.rpc('increment', {
                        table_name: 'wallets', 
                        row_id: userId,
                        column_name: 'eur_balance',
                        x: amount
                    });
                }

                // Create wallet transaction record
                await supabase.from('wallet_transactions').insert({
                    to_user_id: userId,
                    wallet_id: (await supabase
                        .from('wallets')
                        .select('id')
                        .eq('user_id', userId)
                        .single()
                    ).data?.id,
                    transaction_type: 'deposit',
                    currency: currency,
                    amount: amount,
                    status: 'completed',
                    reference_id: session.payment_intent,
                    metadata: metadata
                });
            }
        }

        // Handle payment_intent.succeeded event
        if (event.type === 'payment_intent.succeeded') {
            const paymentIntent = event.data.object;
            
            await supabase
                .from('stripe_payments')
                .update({ 
                    status: 'succeeded',
                    updated_at: new Date().toISOString()
                })
                .eq('stripe_payment_intent_id', paymentIntent.id);
        }

        // Return the Stripe checkout session
        return new Response(JSON.stringify({ received: true }), {
            headers: {
                ...corsHeaders,
                'Content-Type': 'application/json'
            },
            status: 200
        });

    } catch (error) {
        return new Response(JSON.stringify({
            error: error.message
        }), {
            headers: {
                ...corsHeaders,
                'Content-Type': 'application/json'
            },
            status: 400
        });
    }
});