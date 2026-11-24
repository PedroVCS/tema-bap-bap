{#
  Subscription Product Form
  Form for editing the variant and quantity of a subscription product.
#}

<div class="js-subscription-product-container-private subscription-product-form" data-component="subscription-product">

	<div class="order-detail-info">
		<p class="form-label">{{ 'subscriptions.customer_subscriptions.product_current' | t }}</p>
		<div class="order-item-main">
			<div class="order-item-image-container">
				{{ product.featured_image | product_image_url('small') | img_tag(product.name, {class: 'd-block order-item-image'}) }}
			</div>
			<div class="order-item-name">
				<span class="font-weight-bold">{{ product.name }}</span>
				<span class="order-detail-line">{{ current_variant_description }}</span>
			</div>
		</div>
	</div>

	<form method="POST"
	      id="subscription-product-form-{{ subscription.id }}"
	      action="{{ store.customer_subscription_url(subscription) }}/product/"
	      data-variants="{{ variants_json }}"
	      data-discount="{{ subscription.discount_percentage ?? 0 }}"
	      data-submit-label="{{ 'subscriptions.customer_subscriptions.product_save' | t }}"
	      data-out-of-stock-label="{{ 'subscriptions.customer_subscriptions.product_out_of_stock' | t }}"
	      data-unavailable-label="{{ 'subscriptions.customer_subscriptions.product_unavailable' | t }}">

		<input type="hidden" name="product_id" value="{{ product.id }}">
		<input type="hidden" name="variant_id" class="js-subscription-product-variant-id" value="{{ current_variant_id }}">

		{% if product.variations | length > 0 %}
			<div class="grid {{ product.variations | length == 3 ? 'grid-md-3' : 'grid-md-2' }}">
				{% for variation in product.variations %}
					{% embed "snippets/forms/form-select.tpl" with {
						select_label: true,
						select_label_name: variation.name,
						select_for: 'subscription-product-variation-' ~ variation.id,
						select_id: 'subscription-product-variation-' ~ variation.id,
						select_name: 'variation[' ~ variation.id ~ ']',
						select_custom_class: 'js-variation-option',
					} %}
						{% block select_options %}
							{% for option in variation.options %}
								<option value="{{ option.id }}" {{ option.id == current_option_values[variation.id] ? 'selected' : '' }}>{{ option.name }}</option>
							{% endfor %}
						{% endblock select_options %}
					{% endembed %}
				{% endfor %}
			</div>
		{% endif %}

		{% embed 'snippets/forms/form-input.tpl' with {
			type_number: true,
			input_name: 'quantity',
			input_id: 'quantity',
			input_for: true,
			input_label_text: 'subscriptions.customer_subscriptions.quantity' | t,
			input_value: current_quantity,
			input_min: '1',
			input_custom_class: 'js-quantity-input',
			input_group_custom_class: 'js-quantity',
			input_append_content: true,
		} %}
			{% block input_prepend_content %}
				<div class="form-quantity grid grid-3-auto grid-no-gap align-items-center">
					<button type="button" class="js-quantity-down form-quantity-icon btn icon-45px" aria-label="{{ 'subscriptions.customer_subscriptions.quantity_decrease' | t }}">
						<svg class="icon-inline"><use xlink:href="#minus"/></svg>
					</button>
			{% endblock input_prepend_content %}
			{% block input_append_content %}
					<button type="button" class="js-quantity-up form-quantity-icon btn icon-45px" aria-label="{{ 'subscriptions.customer_subscriptions.quantity_increase' | t }}">
						<svg class="icon-inline"><use xlink:href="#plus"/></svg>
					</button>
				</div>
			{% endblock input_append_content %}
		{% endembed %}

		<div class="js-subscription-product-summary-container">
			<h6 class="account-section-title">{{ 'subscriptions.customer_subscriptions.product_summary' | t }}</h6>
			<div class="js-subscription-product-summary">
				<div class="order-totals-line">
					<span>{{ 'subscriptions.customer_subscriptions.product_price' | t }} <span class="js-subscription-product-price-quantity"></span></span>
					<span class="js-subscription-product-price"></span>
				</div>
				{% if subscription.discount_percentage %}
					<div class="order-totals-line">
						<span>{{ 'subscriptions.customer_subscriptions.product_discount' | t | replace('{1}', subscription.discount_percentage) }}</span>
						<span class="js-subscription-product-discount"></span>
					</div>
				{% endif %}
				<div class="order-totals-line">
					<span>{{ 'subscriptions.customer_subscriptions.shipping_every' | t }}</span>
					<span>{{ 'subscriptions.customer_subscriptions.n_days' | t | replace('{1}', subscription.frequency_param) }}</span>
				</div>
				<div class="order-total">
					<span>{{ 'subscriptions.customer_subscriptions.total' | t }}</span>
					<span class="js-subscription-product-total"></span>
				</div>
				<div class="js-subscription-product-shipping-note order-detail-line" hidden>
					<svg class="order-detail-icon icon-inline"><use xlink:href="#info"/></svg>
					{{ 'subscriptions.customer_subscriptions.shipping_disclaimer' | t }}
				</div>
			</div>
		</div>

		<div class="form-actions">
			<button type="button"
			        class="js-modal-open-private js-subscription-product-submit btn btn-primary btn-block"
			        data-target="#subscription-product-confirm-modal-{{ subscription.id }}">
				{{ 'subscriptions.customer_subscriptions.product_save' | t }}
			</button>
		</div>

	</form>

	{% include 'snippets/subscriptions/subscription-product-confirm-modal.tpl' %}

</div>
