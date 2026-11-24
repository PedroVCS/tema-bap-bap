{#
	Structured Data
	Renders schema.org JSON-LD for the current page (Product, BlogPosting, Blog, or WebPage with breadcrumbs).
	Variants are selected by the optional `item` and `blog_item` flags or the page `template`.
#}
{# JSON string literal, quotes included; invalid UTF-8 becomes U+FFFD instead of failing the whole block #}
{% macro json_string(text) %}
{{- text | default('') | json_encode(constant('JSON_UNESCAPED_UNICODE') b-or constant('JSON_HEX_TAG') b-or constant('JSON_INVALID_UTF8_SUBSTITUTE')) | raw -}}
{% endmacro %}

{#
	Descriptions: `plain` decodes the entities the platform pre-applies to some (home page_description) and strips
	tags, which also cuts a literal `<` followed by text; then the five entities `plain` keeps, `&amp;` last
#}
{% macro json_description(text) %}
{{- _self.json_string(text | plain | replace('&quot;', '"') | replace('&#039;', "'") | replace('&lt;', '<') | replace('&gt;', '>') | replace('&amp;', '&')) -}}
{% endmacro %}

{# Calculate subscription price for subscription only products - computed once for both item and product page #}
{% if item or template == 'product' %}
	{% set is_subscription_only = product.isSubscribable() and product.isSubscriptionOnly() %}
	{% set product_original_price = product.compare_at_price ? product.compare_at_price : product.price %}
	{% set structured_data_price = product.price %}

	{% if is_subscription_only %}
		{% set subscription_data = product.getSubscriptionData() %}
		{% set subscription_discount = subscription_data.getMaxDiscountAvailableForSubscription() %}
		{% set combines_with_price_discounts = subscription_data.combinesWithPriceDiscounts() %}
		{% set product_has_price_discount = product.compare_at_price and product.compare_at_price > product.price %}

		{% if combines_with_price_discounts and product_has_price_discount %}
			{# CASE: Combined discounts - apply BOTH discounts on the base price #}
			{% set product_discount_percentage = ((product.compare_at_price - product.price) / product.compare_at_price) * 100 %}
			{% set product_discount_amount = product_original_price * (product_discount_percentage / 100) %}
			{% set subscription_discount_amount = subscription_discount ? (product_original_price * (subscription_discount / 100)) : 0 %}
			{% set structured_data_price = product_original_price - product_discount_amount - subscription_discount_amount %}
		{% elseif subscription_discount %}
			{# CASE: Only subscription discount #}
			{% set structured_data_price = product_original_price * (1 - subscription_discount/100) %}
		{% endif %}
	{% endif %}

	{# Top-level Product entity, shared by the product cards and the PDP main product #}
	{% set product_structured_data %}
	<script type="application/ld+json" data-component='structured-data.item'>
	{
		"@context": "https://schema.org/",
		"@type": "Product",
		"mainEntityOfPage": {
			"@type": "WebPage",
			"@id": "{{ product.canonical_url }}"
		},
		"name": {{ _self.json_string(product.name) }},
		"image": "{{ 'https:' ~ product.featured_image | product_image_url('large') }}",
		"description": {{ _self.json_description(product.seo_description) }},
		{% if store_has_replace_sku_microdata_tag %}
		"productID": {{ _self.json_string(product.get_product_variant_meta_content_id(store_has_preexisting_meta_catalog_tag, store_has_meta_track_product_groups_tag)) }},
		{% elseif product.sku %}
		"sku": {{ _self.json_string(product.sku) }},
		{% endif %}
		{# Only valid GTIN lengths: a free-text barcode would be flagged by Google as an invalid identifier #}
		{% if product.barcode matches '/^([0-9]{8}|[0-9]{12,14})$/' %}
		"gtin": {{ _self.json_string(product.barcode) }},
		{% endif %}
		{% if product.brand %}
			"brand": {
				"@type": "Brand",
				"name": {{ _self.json_string(product.brand) }}
			},
		{% endif %}
		{% if product.weight %}
			"weight": {
				"@type": "QuantitativeValue",
				"unitCode": "{{ product.weight_unit | iso_to_uncefact }}",
				"value": "{{ product.weight }}"
			},
		{% endif %}
		"offers": {
			"@type": "Offer",
			"url": "{{ product.canonical_url }}",
			"priceCurrency": "{{ product.currency }}",
			"price": "{{ structured_data_price / 100 }}",
			"availability": "http://schema.org/{{ product.stock_control ? (product.stock > 0 ? 'InStock' : 'OutOfStock') : 'InStock' }}",
			{% if product.stock_control %}
				"inventoryLevel": {
					"@type": "QuantitativeValue",
					"value": "{{ product.stock }}"
				},
			{% endif %}
			"seller": {
				"@type": "Organization",
				"name": {{ _self.json_string(store.name) }}
			}
		}
	}
	</script>
	{% endset %}
{% endif %}

{% if item and not product.is_unlisted %}
	{{ product_structured_data }}
{% elseif blog_item %}
		<script type="application/ld+json" data-component='structured-data.blog-post'>
		{
			"@context" : "http://schema.org",
			"@type" : "BlogPosting",
			"headline" : {{ _self.json_string(post.seo_title) }},
		{% if post.author_name %}
			"author" : {{ _self.json_string(post.author_name) }},
		{% endif %}
			"description": {{ _self.json_description(post.seo_description) }},
				"url": "{{ store.url }}/blog/posts/{{ post.handle }}",
				"mainEntityOfPage": {
					"@type": "WebPage",
					"@id": "{{ store.url }}/blog/posts/{{ post.handle }}"
				},
				"datePublished" : "{{ post.published_at }}",
				"dateModified" : "{{ post.updated_at }}",
				"publisher" : {
					"@type" : "Organization",
					"name" : {{ _self.json_string(store.name) }}
				}
		{% if post.thumbnail %}
			,"image" : {
				"@type" : "ImageObject",
				"url" : "{{ post.thumbnail }}"
			}
		{% endif %}
		}
	</script>
{% elseif template == 'blog' %}
	<script type="application/ld+json" data-component='structured-data.blog'>
		{
			"@context": "https://schema.org/",
			"@type": "Blog",
			"@id": "{{ page_info.canonical_url }}",
			"mainEntityOfPage": "{{ page_info.canonical_url }}",
			"name": {{ _self.json_string(page_title) }},
			"description": {{ _self.json_description(page_description) }},
			"publisher": {
				"@type": "Organization",
				"name": {{ _self.json_string(store.name) }}
			},
			"blogPost": [
			{% for post in blog.posts %}
			{
				"@type" : "BlogPosting",
				"headline" : {{ _self.json_string(post.seo_title) }},
				{% if post.author_name %}
					"author" : {{ _self.json_string(post.author_name) }},
				{% endif %}
				"description": {{ _self.json_description(post.seo_description) }},
					"url": "{{ store.url }}/blog/posts/{{ post.handle }}",
					"mainEntityOfPage": {
						"@type": "WebPage",
						"@id": "{{ store.url }}/blog/posts/{{ post.handle }}"
					},
					"datePublished" : "{{ post.published_at }}",
					"dateModified" : "{{ post.updated_at }}",
					"publisher" : {
						"@type" : "Organization",
						"name" : {{ _self.json_string(store.name) }}
					}
				{% if post.thumbnail %}
					,"image" : {
						"@type" : "ImageObject",
						"url" : "{{ post.thumbnail }}"
					}
				{% endif %}
			}{% if loop.index != loop.length %},{% endif %}
			{% endfor %}
		  ]
	  }
	</script>
{% elseif not item %}
	{% if template == 'product' and not product.is_unlisted %}
		{{ product_structured_data }}
	{% endif %}
	<script type="application/ld+json" data-component='structured-data.page'>
	{
		"@context": "https://schema.org/",
		"@type": "WebPage",
		"name": {{ _self.json_string(page_title) }},
		{% if page_description %}
			"description": {{ _self.json_description(page_description) }},
		{% endif %}
		"breadcrumb": {
			"@type": "BreadcrumbList",
			"itemListElement": [
			{
				"@type": "ListItem",
				"position": 1,
				"name": "{{ 'breadcrumbs.home' | t }}",
				"item": "{{ store.url }}"
			}{% if template != 'home' %},{% endif %}
			{% if template == 'page' %}
				{
					"@type": "ListItem",
					"position": 2,
					"name": {{ _self.json_string(page.name) }},
					"item": "{{ page.url }}"
				}
			{% elseif template == 'cart' %}
				{
					"@type": "ListItem",
					"position": 2,
					"name": "{{ 'breadcrumbs.cart' | t }}",
					"item": "{{ store.url }}{{ store.cart_url }}"
				}
			{% elseif template == 'search' %}
				{
					"@type": "ListItem",
					"position": 2,
					"name": "{{ 'breadcrumbs.search_results' | t }}",
					"item": "{{ store.url }}{{ store.search_url }}"
				}
			{% elseif template == 'account.order' %}
				{
					"@type": "ListItem",
					"position": 2,
					"name": "{{ 'breadcrumbs.order_number' | t | replace('{1}', order.number) }}",
					"item": "{{ store.url }}{{ store.customer_order_url(order) }}"
				}
			{% else %}
				{% for crumb in breadcrumbs %}
					{
						"@type": "ListItem",
						"position": {{ loop.index + 1 }},
						"name": {{ _self.json_string(crumb.name) }},
						"item": "{{ store.url }}{{ crumb.url }}"
					}{% if not crumb.last %},{% endif %}
				{% endfor %}
			{% endif %}
			]
		}
	}
	</script>
{% endif %}
