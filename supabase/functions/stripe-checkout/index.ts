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

        // Get the request body
        const { 
            amount, 
            currency = 'usd', 
            success_url, 
            cancel_url, 
            customer_email,
            metadata = {}
        } = await req.json();

        // Create or retrieve Stripe customer
        let customer;
        const existingCustomers = await stripe.customers.list({
            email: customer_email,
            limit: 1
        });

        if (existingCustomers.data.length > 0) {
            customer = existingCustomers.data[0];
        } else {
            customer = await stripe.customers.create({
                email: customer_email
            });
        }

        // Create a Stripe checkout session
        const session = await stripe.checkout.sessions.create({
            customer: customer.id,
            payment_method_types: ['card'],
            line_items: [
                {
                    price_data: {
                        currency: currency,
                        product_data: {
                            name: 'TamTam Payment',
                            description: 'TamTam app transaction'
                        },
                        unit_amount: Math.round(amount * 100), // Convert to cents
                    },
                    quantity: 1,
                },
            ],
            mode: 'payment',
            success_url: success_url,
            cancel_url: cancel_url,
            metadata: metadata
        });

        // Store payment intent in database
        const { data: authData } = await supabase.auth.getUser();
        if (authData?.user) {
            await supabase.from('stripe_payments').insert({
                user_id: authData.user.id,
                stripe_payment_intent_id: session.payment_intent,
                amount: Math.round(amount * 100),
                currency: currency,
                status: 'pending',
                metadata: metadata
            });
        }

        // Return the Stripe checkout session
        return new Response(JSON.stringify({
            sessionId: session.id,
            url: session.url
        }), {
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