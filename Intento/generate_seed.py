import json

def generate_sql():
    with open('Intento/Resources/catalog.json', 'r') as f:
        data = json.load(f)
    
    products = data.get('products', [])
    
    sql_statements = ["-- Auto-generated SQL seed for products"]
    sql_statements.append("BEGIN;")
    
    updates = []
    
    for product in products:
        sku = product.get('sku')
        name = product.get('name', '').replace("'", "''")
        brand = product.get('brand', '').replace("'", "''")
        category = product.get('category', '').replace("'", "''")
        pack_value = product.get('pack_value')
        pack_unit = product.get('pack_unit', '').replace("'", "''")
        price_paise = product.get('price_paise')
        
        dietary_tags = json.dumps(product.get('dietary_tags', [])).replace("'", "''")
        tags = json.dumps(product.get('tags', [])).replace("'", "''")
        seasonal_tags = json.dumps(product.get('seasonal_tags', [])).replace("'", "''")
        
        servings_per_pack = product.get('servings_per_pack')
        nutrition_score = product.get('nutrition_score')
        
        healthier_alternative_sku = product.get('healthier_alternative_sku')
        if healthier_alternative_sku:
            healthier_alternative_sku_sql = f"'{healthier_alternative_sku}'"
            updates.append(f"UPDATE public.products SET healthier_alternative_sku = {healthier_alternative_sku_sql} WHERE sku = '{sku}';")
        
        is_refill_available = str(product.get('is_refill_available', False)).lower()
        
        refill_alternative_sku = product.get('refill_alternative_sku')
        if refill_alternative_sku:
            refill_alternative_sku_sql = f"'{refill_alternative_sku}'"
            updates.append(f"UPDATE public.products SET refill_alternative_sku = {refill_alternative_sku_sql} WHERE sku = '{sku}';")
        
        is_reusable_alternative = str(product.get('is_reusable_alternative', False)).lower()
        
        image_name = product.get('image_name')
        image_name_sql = f"'{image_name}'" if image_name else "NULL"
        
        stock_status = product.get('stock_status', 'in_stock').replace("'", "''")
        quantity_available = product.get('quantity_available', 0)
        is_active = str(product.get('is_active', True)).lower()
        
        sql = f"""INSERT INTO public.products (
    sku, name, brand, category, pack_value, pack_unit, price_paise,
    dietary_tags, tags, seasonal_tags, servings_per_pack, nutrition_score,
    healthier_alternative_sku, is_refill_available, refill_alternative_sku,
    is_reusable_alternative, image_name, stock_status, quantity_available, is_active
) VALUES (
    '{sku}', '{name}', '{brand}', '{category}', {pack_value}, '{pack_unit}', {price_paise},
    '{dietary_tags}'::jsonb, '{tags}'::jsonb, '{seasonal_tags}'::jsonb, {servings_per_pack}, {nutrition_score},
    NULL, {is_refill_available}, NULL,
    {is_reusable_alternative}, {image_name_sql}, '{stock_status}', {quantity_available}, {is_active}
) ON CONFLICT (sku) DO UPDATE SET
    name = EXCLUDED.name,
    brand = EXCLUDED.brand,
    category = EXCLUDED.category,
    pack_value = EXCLUDED.pack_value,
    pack_unit = EXCLUDED.pack_unit,
    price_paise = EXCLUDED.price_paise,
    dietary_tags = EXCLUDED.dietary_tags,
    tags = EXCLUDED.tags,
    seasonal_tags = EXCLUDED.seasonal_tags,
    servings_per_pack = EXCLUDED.servings_per_pack,
    nutrition_score = EXCLUDED.nutrition_score,
    is_refill_available = EXCLUDED.is_refill_available,
    is_reusable_alternative = EXCLUDED.is_reusable_alternative,
    image_name = EXCLUDED.image_name,
    stock_status = EXCLUDED.stock_status,
    quantity_available = EXCLUDED.quantity_available,
    is_active = EXCLUDED.is_active;"""
        
        sql_statements.append(sql)
        
    sql_statements.extend(updates)
    sql_statements.append("COMMIT;")
    
    with open('seed_products.sql', 'w') as f:
        f.write('\\n'.join(sql_statements))

if __name__ == '__main__':
    generate_sql()
