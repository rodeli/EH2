#!/bin/bash

# Script to create D1 database and run initial migration
# This is a quick setup option that doesn't require Terraform

set -e

echo "🚀 Creating D1 database for Escriturashoy..."

# Database name
DB_NAME="escriturashoy-staging-db"

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "❌ Wrangler is not installed."
    echo "   Install it with: npm install -g wrangler"
    echo "   Or use: npx wrangler"
    exit 1
fi

# Check if database already exists
echo "📋 Checking if database exists..."
if wrangler d1 list | grep -q "$DB_NAME"; then
    echo "✅ Database '$DB_NAME' already exists!"
    echo ""
    echo "To get the database ID, run:"
    echo "  wrangler d1 list"
    echo ""
    echo "Then update apps-api/workers/wrangler.toml with the database_id"
    exit 0
fi

# Create the database
echo "🔨 Creating database '$DB_NAME'..."
OUTPUT=$(wrangler d1 create "$DB_NAME" 2>&1)

# Show the output for debugging
echo "$OUTPUT"
echo ""

# Extract database_id from output (macOS-compatible)
# Try pattern: database_id = "abc123..."
DB_ID=$(echo "$OUTPUT" | grep -oE 'database_id = "[^"]+"' | sed 's/database_id = "//;s/"//' || echo "")

if [ -z "$DB_ID" ]; then
    # Try alternative pattern: database-id: abc123...
    DB_ID=$(echo "$OUTPUT" | grep -oE 'database-id[^:]*: [a-f0-9-]{36,}' | grep -oE '[a-f0-9-]{36,}' | head -1 || echo "")
fi

if [ -z "$DB_ID" ]; then
    # Try to find any UUID-like string after "database"
    DB_ID=$(echo "$OUTPUT" | grep -i "database" | grep -oE '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}' | head -1 || echo "")
fi

if [ -z "$DB_ID" ]; then
    echo "⚠️  Could not automatically extract database_id from output."
    echo ""
    echo "Please look at the output above and find the database_id."
    echo "It's usually shown in a format like:"
    echo "  database_id = \"abc123...\""
    echo "  or"
    echo "  [[d1_databases]]"
    echo "  database_id = \"abc123...\""
    echo ""
    read -p "Enter the database_id: " DB_ID

    if [ -z "$DB_ID" ]; then
        echo "❌ No database_id provided. Exiting."
        echo ""
        echo "Please manually update apps-api/workers/wrangler.toml:"
        echo "  [env.staging]"
        echo "  d1_databases = ["
        echo "    { binding = \"DB\", database_name = \"$DB_NAME\", database_id = \"YOUR_DATABASE_ID\" }"
        echo "  ]"
        exit 1
    fi
fi

echo "✅ Database created successfully!"
echo "📝 Database ID: $DB_ID"
echo ""

# Update wrangler.toml
WRANGLER_TOML="apps-api/workers/wrangler.toml"

if [ -f "$WRANGLER_TOML" ]; then
    echo "📝 Updating wrangler.toml..."

    # Check if d1_databases section exists
    if grep -q "d1_databases" "$WRANGLER_TOML"; then
        # Uncomment and update existing section
        sed -i.bak "s/# d1_databases = \[/d1_databases = [/" "$WRANGLER_TOML"
        sed -i.bak "s/#   { binding = \"DB\", database_name = \".*\", database_id = \".*\" }/  { binding = \"DB\", database_name = \"$DB_NAME\", database_id = \"$DB_ID\" }/" "$WRANGLER_TOML"
        rm -f "$WRANGLER_TOML.bak"
    else
        # Add new section
        cat >> "$WRANGLER_TOML" <<EOF

# D1 Database binding
[env.staging]
d1_databases = [
  { binding = "DB", database_name = "$DB_NAME", database_id = "$DB_ID" }
]
EOF
    fi

    echo "✅ Updated $WRANGLER_TOML"
else
    echo "⚠️  $WRANGLER_TOML not found. Please manually add:"
    echo ""
    echo "  [env.staging]"
    echo "  d1_databases = ["
    echo "    { binding = \"DB\", database_name = \"$DB_NAME\", database_id = \"$DB_ID\" }"
    echo "  ]"
fi

echo ""
echo "🎉 Database setup complete!"
echo ""
echo "Next steps:"
echo "1. Run the migration:"
echo "   cd apps-api/workers"
echo "   wrangler d1 execute $DB_NAME --file=../../db/migrations/001_initial_schema.sql --remote"
echo ""
echo "2. For local development:"
echo "   wrangler d1 execute $DB_NAME --file=../../db/migrations/001_initial_schema.sql --local"

