{# Buy Together Form Block - Static block of the buy-together section; renders a sample in the editor when the product has no offer #}

{% set has_offer = not is_preset_preview and buy_together_products | length > 0 %}
{% set show_sample = is_preset_preview or (is_preview and not has_offer) %}

{% set buy_together_button %}
	{% for sub_block in block.blocks | default([]) %}
		{% if sub_block.type == 'buy-together-button' %}
			{% include 'blocks/buy-together-button.tpl' with {
				block: sub_block,
				button_label: show_sample ? ('product.buy_together.add_to_cart' | t | replace('{1}', 3)) : ('product.add_to_cart' | t),
			} %}
		{% endif %}
	{% endfor %}
{% endset %}

<div class="w-100" {{ block | block_attributes }}>
	{% if has_offer %}
		{% set trigger_price = product.price %}
		{% set trigger_original_price = product.compare_at_price > product.price ? product.compare_at_price : product.price %}
		{% set promotion_id = (buy_together_products | first).promotionId %}

		{# Bundle discount applied on the product's promo price. #}
		{% set buy_together_offers = {} %}
		{% for linked_product in buy_together_products %}
			{% set original_price = linked_product.product.compare_at_price ?: linked_product.product.price %}
			{% set promo_price = (linked_product.product.price * (100 - linked_product.discountValue) / 100) | round %}
			{# 'p' prefix keeps the key a string: Twig's merge (array_merge) renumbers integer keys. #}
			{% set buy_together_offers = buy_together_offers | merge({
				('p' ~ linked_product.product.id): {
					index: loop.index0,
					original_price: original_price,
					promo_price: promo_price,
					discount_percentage: original_price > 0 ? (100 - (promo_price / original_price * 100)) : linked_product.discountValue,
					bundle_percentage: linked_product.discountValue,
				},
			}) %}
		{% endfor %}

		{% set buy_together_items = [product] | merge(buy_together_products | map(linked_product => linked_product.product)) %}

		{# Checkboxes are shown with more than one linked product. #}
		{% set selectable_linked = buy_together_products | length > 1 %}

		<div class="js-buy-together buy-together" data-component="cross-sell-widget">
			<form
				id="buy-together-form"
				class="js-buy-together-form buy-together-form"
				data-component="cross-sell-widget.form"
				method="post"
				action="{{ store.language_prefix }}/cart/add_multiple_to_cart/"
				data-trigger-price="{{ trigger_price }}"
				data-trigger-original-price="{{ trigger_original_price }}"
				{% if product.variations | length > 0 %}data-trigger-has-variants{% endif %}
				data-savings-label="{{ 'product.compare_price_saving_message' | t }} {1}"
				data-add-label="{{ 'product.buy_together.add_to_cart' | t }}"
				data-default-add-label="{{ 'product.add_to_cart' | t }}"
				data-no-stock-label="{{ 'general.no_stock' | t }}"
				data-added-notification="{{ 'product.buy_together.added_notification' | t }}"
				data-added-notification-savings="{{ 'product.buy_together.added_notification_savings' | t }}"
				data-remove-label="{{ 'product.buy_together.remove_product' | t }}"
				data-promotion-id="{{ promotion_id }}"
				data-added-label="{{ 'cart.added_to_cart' | t }}"
			>

				{# Promotion id shared by all linked products. #}
				<input type="hidden" name="cross_selling_promotion_id" value="{{ promotion_id }}" />

				<div id="buy-together-products" class="buy-together-content" data-store="buy-together-products" data-component="cross-sell-widget.products" data-related-amount="{{ buy_together_items | length }}">
					{% for item in buy_together_items %}
						{% include 'snippets/product-list/product-item/item.tpl' with {
							product: item,
							slider: false,
							reduced_item: true,
							item_data_component: 'cross-sell-widget.product',
							buy_together: {
								trigger_id: product.id,
								offers: buy_together_offers,
								selectable: selectable_linked,
							},
						} %}
					{% endfor %}

					<div class="js-buy-together-summary buy-together-summary">
						<div class="d-flex flex-column">
							<span class="js-buy-together-total-compare product-item-price-compare" data-component="cross-sell-widget.compare-price"></span>
							<span class="js-buy-together-total buy-together-total" data-component="cross-sell-widget.price"></span>
							<span class="js-buy-together-savings buy-together-savings" data-component="cross-sell-widget.savings"></span>
						</div>

						{{ buy_together_button }}

						{% if settings.ajax_cart %}
							{# Replaces the CTA once the bundle is in the cart; store.js picks singular or plural from the items added. #}
							<div class="js-buy-together-added-message product-added-message" style="display: none;" data-component="cross-sell-widget.added-message">
								<svg class="product-added-icon icon-inline"><use xlink:href="#check"/></svg>
								<span class="product-added-message-text">
									<span class="js-buy-together-added-text" data-singular="{{ 'product.already_added' | t }}" data-plural="{{ 'product.already_added_plural' | t }}">{{ 'product.already_added_plural' | t }}</span><a href="#" class="js-modal-open-private product-added-message-link btn-link" data-target="#modal-cart">{{ 'product.view_cart' | t }}</a>
								</span>
							</div>
						{% endif %}

						<div
							class="alert alert-warning"
							style="display: none;"
							data-component="buy-together.error"
							data-message="{{ 'cart.error_messages.unavailable_product_named' | t }}"
							data-message-plural="{{ 'cart.error_messages.unavailable_product_named_plural' | t }}"
							data-message-cross-selling-promotion-already-applied="{{ 'cart.error_messages.cross_selling_promotion_already_applied' | t }}"
						></div>

					</div>
				</div>

				{% include 'snippets/modals/buy-together-modal.tpl' with {
					buy_together_items: buy_together_items,
					buy_together_offers: buy_together_offers,
					trigger_price: trigger_price,
					trigger_original_price: trigger_original_price,
				} %}
			</form>
		</div>
	{% else %}
		{% set sample_offer = { original_price: 100000, promo_price: 85000, discount_percentage: 15, bundle_percentage: 15 } %}
		<div class="buy-together">
			<div class="buy-together-content">
				{% for i in 1..3 %}
					{% include 'snippets/product-list/product-item/item.tpl' with {
						product: {
							'is_placeholder': true,
							'id': 'sample-' ~ i,
							'name': 'product_item.example_name' | t,
							'url': '#',
							'display_price': true,
							'price': 100000,
							'has_stock': true,
							'stock': 1,
							'placeholder_image_url': ('images/placeholders/products/product-' ~ i ~ '.webp') | static_url,
							'featured_image': { 'dimensions': { 'width': 440, 'height': 600 }, 'alt': 'product_item.example_name' | t },
						},
						slider: false,
						reduced_item: true,
						buy_together: {
							trigger_id: 'sample-1',
							offers: {
								'psample-2': sample_offer | merge({ index: 0 }),
								'psample-3': sample_offer | merge({ index: 1 }),
							},
							selectable: true,
						},
					} %}
				{% endfor %}
				<div class="buy-together-summary">
					<div class="d-flex flex-column">
						<span class="product-item-price-compare">{{ 300000 | money }}</span>
						<span class="buy-together-total">{{ 270000 | money }}</span>
						<span class="buy-together-savings">{{ 'product.compare_price_saving_message' | t }} {{ 30000 | money }}</span>
					</div>

					{{ buy_together_button }}

				</div>
			</div>
		</div>
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.buy_together_form",
  "icon": "ShoppingCartIcon",
  "limit": 1,
  "static": true,
  "deletable": false,
  "duplicatable": false,
  "hideable": false,
  "locked_blocks": true,
  "blocks": [
    { "type": "buy-together-button", "static": true }
  ],
  "settings": []
}
{% endschema %}
