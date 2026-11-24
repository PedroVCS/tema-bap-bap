{#
  Subscription Product Confirm Modal
  Modal for confirming a subscription product variant/quantity change.
#}

{% set modal_id = 'subscription-product-confirm-modal-' ~ subscription.id %}

{% embed 'snippets/modals/modal.tpl' with {
	modal_id: modal_id,
	data_component: 'subscription-product-confirm-modal',
	title: 'subscriptions.customer_subscriptions.product_confirm_modal_title' | t,
	position: {
		appear_from: 'bottom',
	},
	layout: {
		width_mobile: 'small',
		width_desktop: 'small',
	},
	modal_classes: {
		close_icon: 'icon-inline',
	},
} %}
	{% block modal_body %}
		<div class="form-description">
			<p>{{ 'subscriptions.customer_subscriptions.product_confirm_modal_message' | t }}</p>
		</div>
		<div class="form-actions">
			<button type="button" class="js-modal-close-private btn-link" data-target="#{{ modal_id }}" data-modal-url="{{ modal_id }}">
				{{ 'subscriptions.customer_subscriptions.product_confirm_modal_cancel' | t }}
			</button>
			<button type="submit" form="subscription-product-form-{{ subscription.id }}" class="btn btn-primary">
				{{ 'subscriptions.customer_subscriptions.product_confirm_modal_confirm' | t }}
			</button>
		</div>
	{% endblock %}
{% endembed %}
