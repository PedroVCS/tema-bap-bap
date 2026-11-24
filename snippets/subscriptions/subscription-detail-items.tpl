{#
  Subscription Detail Items
  Last order items list for the subscription detail view.
#}

<div class="subscription-detail-items" data-store="account-subscription-items" data-component="account-subscription-items">
	<div class="order-items-header bottom-line d-none d-md-grid">
		<div>{{ 'order.product' | t }}</div>
		<div class="order-items-header-center">{{ 'general.price' | t }}</div>
		<div class="order-items-header-center">{{ 'general.quantity' | t }}</div>
		<div class="order-items-header-total">{{ 'general.total' | t }}</div>
	</div>
	<div class="order-detail">
		{% set enable_subscription_product = true %}
		{% set display_items = subscription_product ? [subscription_product] : last_order_items %}
		{% for item in display_items %}
			{%- set item_subtotal = subscription_product ? item.total : item.subtotal -%}
			<div class="order-item">
				<div class="order-item-main">
					<div class="order-item-image-container">
						{{ item.featured_image | product_image_url("small") | img_tag(item.featured_image.alt, {class: 'd-block order-item-image'}) }}
					</div>
					<div class="order-item-name">
						<span class="font-weight-bold">{{ item.name }}</span> <span class="order-items-header-center d-inline-block d-md-none">x{{ item.quantity }}</span>
						{% if item.variant_description %}
							<span class="d-block order-detail-line">{{ item.variant_description }}</span>
						{% endif %}
						{% if enable_subscription_product and subscriber_permissions.can_change_product and subscription.is_active %}
							<a class="btn-link" href="{{ store.customer_subscription_url(subscription) }}/product/">
								{{ 'subscriptions.customer_subscriptions.change_product' | t }}
							</a>
						{% endif %}
					</div>
				</div>
				<div class="order-items-header-center d-none d-md-block">
					{{ item.unit_price | money }}
				</div>
				<div class="order-items-header-center d-none d-md-block">
					{{ item.quantity }}
				</div>
				<div class="order-items-header-total">
					{{ item_subtotal | money }}
				</div>
			</div>
		{% endfor %}
	</div>
</div>
