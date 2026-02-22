#!/bin/bash
# A strategist's tool to ensure branding consistency across the NXT suite

PRODUCT_NAME=$1 # e.g., "eventnxt", "castnxt", "planxt"

echo "Initializing $PRODUCT_NAME architecture..."

# 1. Create the Strategy directory if it doesn't exist
mkdir -p lib/omniauth/strategies

# 2. Verify the strategy file matches the product name
if [ -f "lib/omniauth/strategies/$PRODUCT_NAME.rb" ]; then
    echo "✅ Strategy file located."
else
    echo "❌ Missing strategy file. Please create lib/omniauth/strategies/$PRODUCT_NAME.rb"
fi

# 3. Check for legacy 'events360' ghosts
if [ -f "lib/omniauth/strategies/events360.rb" ]; then
    echo "⚠️ Legacy file found! Removing to prevent constant collision..."
    rm lib/omniauth/strategies/events360.rb
fi

echo "Setup complete. Ready for Aider development on $PRODUCT_NAME."
