{# Buy together variant selector modal. #}

{% embed 'snippets/modals/modal.tpl' with {
	modal_id: 'buy-together-variant-modal',
	title: 'product.buy_together.confirm_title' | t,
	position: {
		appear_from: 'bottom',
	},
	layout: {
		width_mobile: 'full',
		width_desktop: 'small',
	},
	modal_footer: true,
	modal_classes: {
		close_icon: 'icon-inline',
	},
	data_component: 'cross-sell-widget.variants-modal',
	close_data_component: 'cross-sell-widget.variants-modal.close',
} %}
	{% block modal_body %}
		{% for modal_product in buy_together_items %}
			{% set offer = buy_together_offers['p' ~ modal_product.id] | default(null) %}
			{% set has_variants = modal_product.variations | length > 0 %}
			{# The variant interface already drops empty option values and builds "Name (A, B)". #}
			{% set selected_variant = modal_product.selected_or_first_available_variant %}
			{% set selected_option_text = selected_variant.options | join(', ') %}
			{% set display_name = selected_variant.name %}

			{% if offer %}
				{% set row_price = offer.promo_price %}
				{% set row_compare_price = offer.original_price %}
				{% set row_discount_percentage = offer.discount_percentage %}
			{% else %}
				{% set row_price = trigger_price %}
				{% set row_compare_price = trigger_original_price > trigger_price ? trigger_original_price : null %}
				{% set row_discount_percentage = row_compare_price ? modal_product.promotional_price_percentage : 0 %}
			{% endif %}

			{# Row: thumb | name + option | prices + remove, with the variant pickers below. #}
			<div class="js-buy-together-modal-row buy-together-modal-row" data-component="cross-sell-widget.variants-modal.product" data-product-name="{{ modal_product.name }}" {% if offer %}data-buy-together-index="{{ offer.index }}"{% else %}data-buy-together-trigger{% endif %}>
				<div class="buy-together-modal-item">
					<div class="buy-together-modal-thumb">
						{% include 'snippets/image.tpl' with {
							image_src: modal_product.featured_image,
							product_image: true,
							image_lazy_js: true,
							image_alt: modal_product.name,
							image_classes: 'js-buy-together-modal-thumb-image buy-together-modal-thumb-image',
							image_thumbs: ['thumb', 'small', 'medium'],
						} %}
					</div>
					<div class="buy-together-modal-info">
						{% if not offer %}
							<div class="buy-together-modal-this">{{ 'product.buy_together.this_product' | t }}</div>
						{% endif %}
						<div data-component="cross-sell-widget.variants-modal.product.name">{{ modal_product.name }}</div>
						{% if has_variants %}
							<div class="buy-together-modal-option">
								{{ 'product.buy_together.selected_option' | t }}: <span class="js-buy-together-modal-option-value" data-component="cross-sell-widget.variants-modal.product.variant-name">{{ selected_option_text }}</span>
							</div>
							<button
								type="button"
								class="js-buy-together-modal-toggle buy-together-modal-toggle btn-link"
								aria-expanded="false"
								data-open-label="{{ 'product.buy_together.change_option' | t }}"
								data-close-label="{{ 'product.buy_together.close_option' | t }}"
								data-component="cross-sell-widget.variants-modal.product.show-variant-selector"
							>{{ 'product.buy_together.change_option' | t }}</button>
						{% endif %}
					</div>
					<div class="buy-together-modal-prices">
						{# Price, or the "no stock" label when the chosen variant is unavailable. #}
						<div class="js-buy-together-modal-price-container">
							<div class="js-buy-together-modal-compare buy-together-modal-compare" {% if not row_compare_price %}style="display: none;"{% endif %}>
								<span class="js-buy-together-discount buy-together-modal-discount text-accent" data-component="cross-sell-widget.variants-modal.product.discount-percentage"><span class="js-offer-percentage">{{ row_discount_percentage | round }}</span>% {{ 'payments.off_label' | t }}</span>
								<span class="js-compare-price-display price-compare" data-component="cross-sell-widget.variants-modal.product.compare-price">{{ row_compare_price ? row_compare_price | money }}</span>
							</div>
							<div class="js-price-display" data-component="cross-sell-widget.variants-modal.product.price">{{ row_price | money }}</div>
						</div>
						<span class="js-buy-together-modal-no-stock" style="display: none;" data-component="cross-sell-widget.variants-modal.product.no-stock">{{ 'general.no_stock' | t }}</span>
						{% if offer %}
							{% set remove_label = 'product.buy_together.remove_product' | t | replace('{1}', display_name) %}
							<button
								type="button"
								class="js-buy-together-modal-remove buy-together-modal-remove btn-link"
								title="{{ remove_label }}"
								aria-label="{{ remove_label }}"
								data-component="cross-sell-widget.variants-modal.product.remove"
							>
								<svg class="icon-inline"><use xlink:href="#trash"/></svg>
							</button>
						{% endif %}
					</div>
				</div>

				{% if has_variants %}
					{# Only what the modal reads: variant lookup by options, price, stock and image. #}
					{% set modal_variants_data = modal_product.variants_object_reduced() | map(variant => {
						id: variant.id,
						option0: variant.option0,
						option1: variant.option1,
						option2: variant.option2,
						price_number: variant.price_number,
						compare_at_price_number: variant.compare_at_price_number,
						available: variant.available,
						contact: variant.contact,
						image: variant.image,
						image_url: variant.image_url,
					}) %}
					<div class="js-buy-together-modal-variants buy-together-modal-variants" style="display: none;" data-variants="{{ modal_variants_data | json_encode }}">
						{% include 'snippets/product/product-variants.tpl' with {
							product: modal_product,
							quickshop: true,
							variants_classes: 'mb-0',
							variants_id_prefix: 'bt_' ~ modal_product.id ~ '_variation_',
							variant_data_component: 'cross-sell-widget.variants-modal.product.variant',
							variant_option_data_component: 'cross-sell-widget.variants-modal.variant-option',
						} %}
					</div>
				{% endif %}
			</div>
		{% endfor %}
	{% endblock %}
	{% block modal_foot %}
		<div class="buy-together-modal-total-row">
			<span class="buy-together-modal-total-label">{{ 'general.total' | t }}:</span>
			<div class="buy-together-modal-totals">
				<div class="js-buy-together-modal-total buy-together-modal-total" data-component="cross-sell-widget.variants-modal.total"></div>
				<div class="js-buy-together-modal-savings buy-together-modal-savings text-accent" data-component="cross-sell-widget.variants-modal.savings"></div>
			</div>
		</div>
		<input type="submit" form="buy-together-form" class="js-buy-together-modal-confirm btn btn-primary w-100" value="{{ 'product.buy_together.confirm_and_add' | t }}" data-component="cross-sell-widget.variants-modal.confirm-variants" />
		{% include 'snippets/placeholders/button-placeholder.tpl' with { custom_class: 'w-100' } %}
	{% endblock %}
{% endembed %}
