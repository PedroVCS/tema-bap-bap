{#
  Shipping Options
  Renders available shipping methods and pickup options for product or cart.
#}
{% if options %}
    {% if store.show_shipping_emergency_message %}
        <div class="shipping-emergency-container">
            <div class="alert alert-warning">{{ store.shipping_emergency_message }}</div> 
        </div>
    {% endif %}

    <div class="{% if cart.items_count > 0 and not cart.free_shipping.cart_has_free_shipping %}js-product-shipping-label{% endif %} shipping-add-product-notice" style="display: none;">
        {{ 'shipping.options_if_add_product' | t | raw }}
    </div>

    {# Check for only delivery featured options #}

    {% set has_featured_shipping = false %}

    {% for option in options_to_show if option.shipping_type == 'ship' or option.shipping_type == 'delivery' or (option.method == 'table' and option.shipping_type == 'custom') %}
        {% if option |length >= 1 %}
            {% set has_featured_shipping = true %}
        {% endif %}
    {% endfor %}

    {# Check for only non featured delivery options #}

    {% set has_non_featured_shipping = false %}

    {% for option in options_to_hide if option.shipping_type == 'ship' or option.shipping_type == 'delivery' or (option.method == 'table' and option.shipping_type == 'custom') %}
        {% if option |length >= 1 %}
            {% set has_non_featured_shipping = true %}
        {% endif %}
    {% endfor %}

    {# Pickup featured options #}

    {% set has_non_featured_pickup = false %}
    {% set has_featured_pickup = false %}

    {# Check for only pickup featured options #}

    {% for option in options_to_show if option.shipping_type == 'pickup' and option.method != 'branch' %}
        {% if option |length >= 1 %}
            {% set has_featured_pickup = true %}
        {% endif %}
    {% endfor %}

    {# Check for only non featured pickup options #}

    {% for option in options_to_hide if option.shipping_type == 'pickup' and option.method != 'branch' %}
        {% if option |length >= 1 %}
            {% set has_non_featured_pickup = true %}
        {% endif %}
    {% endfor %}

    {# Shipping options #}

    {% if has_featured_shipping %}

        <div class="shipping-options">
            <div class="shipping-options-heading">
                {% include 'snippets/icon.tpl' with { name: 'truck', size: 20 } %}
                <span>{{ 'shipping.home_delivery' | t }}</span>
            </div>

            <ul class="radio-button-container list-unstyled">

                {# List only delivery featured options #}

                {% for option in options_to_show if option.shipping_type == 'ship' or option.shipping_type == 'delivery' or (option.method == 'table' and option.shipping_type == 'custom') %}
                    {% include "snippets/shipping/shipping-calculator-item.tpl" with {'featured_option': true} %}
                {% endfor %}

                {% if has_non_featured_shipping %}

                    <div class="js-other-shipping-options shipping-hidden-options" style="display: none;">

                        {# List only delivery non featured options #}

                        {% for option in options_to_hide if option.shipping_type == 'ship' or option.shipping_type == 'delivery' or (option.method == 'table' and option.shipping_type == 'custom') %}
                            {% include "snippets/shipping/shipping-calculator-item.tpl" %}
                        {% endfor %}
                    </div>

                    <div class="js-toggle-more-shipping-options js-show-more-shipping-options shipping-toggle-more">
                        <a href="#" class="btn-link font-small">
                            <span class="js-shipping-see-more">
                                {{ 'shipping.view_more_shipping' | t }}
                            </span>
                            <span class="js-shipping-see-less" style="display: none;">
                                {{ 'shipping.view_less_shipping' | t }}
                            </span>
                        </a>
                    </div>
                    

                {% endif %}

            </ul>
        </div>

    {% endif %}

    {# Pickup options #}

    {% if has_featured_pickup %}

        <div class="shipping-options">
            <div class="shipping-options-heading">
                {% include 'snippets/icon.tpl' with { name: 'location', size: 20 } %}
                <span>{{ 'shipping.pickup_at' | t }}</span>
            </div>

            <ul class="radio-button-container list-unstyled">

                {# List only pickup featured options #}

                {% for option in options_to_show if option.shipping_type == 'pickup' and option.method != 'branch' %}
                    {% include "snippets/shipping/shipping-calculator-item.tpl" with {'featured_option': true, 'pickup' : true} %}
                {% endfor %}

                {% if has_non_featured_pickup %}

                    <div class="js-other-pickup-options shipping-hidden-options" style="display: none;">

                        {# List only pickup non featured options #}

                        {% for option in options_to_hide if option.shipping_type == 'pickup' and option.method != 'branch' %}
                            {% include "snippets/shipping/shipping-calculator-item.tpl" with {'pickup' : true}  %}
                        {% endfor %}
                    </div>

                    <div class="js-toggle-more-shipping-options js-show-other-pickup-options shipping-toggle-more">
                        <a href="#" class="btn-link font-small">
                            <span class="js-shipping-see-more">
                                {{ 'shipping.view_more_pickup' | t }}
                            </span>
                            <span class="js-shipping-see-less" style="display: none;">
                                {{ 'shipping.view_less_pickup' | t }}
                            </span>
                        </a>
                    </div>

                {% endif %}
            </ul>
        </div>

    {% endif %}

    {# Made-to-order notice: the product page shows this product's own time, the cart shows a general note #}
    {% set preparation_product = shipping_preparation.product ?? null %}
    {% set show_product_preparation = variant is not null and preparation_product and preparation_product.days > 0 %}
    {% set show_cart_preparation = variant is null and (shipping_preparation.cart_has_items ?? false) %}

    {% if show_product_preparation or show_cart_preparation %}
        <div class="font-small" data-component="shipping.preparation-note" data-store="shipping-preparation-note">
            {% if show_product_preparation %}
                {% set preparation_unit = preparation_product.saturday and preparation_product.sunday ? 'calendar' : (preparation_product.saturday or preparation_product.sunday ? 'days' : 'business') %}
                {% set preparation_count = preparation_product.days == 1 ? 'singular' : 'plural' %}
                {% set preparation_duration = ('shipping.preparation_' ~ preparation_unit ~ '_' ~ preparation_count) | t(preparation_product.days) %}
                {{ 'shipping.preparation_product_note' | t(preparation_duration) | raw }}
            {% else %}
                {{ 'shipping.preparation_cart_note' | t }}
            {% endif %}
        </div>
    {% endif %}
{% else %}
<span>{{ 'shipping.no_shipping_costs' | t }}</span>
{% endif %}

{# Don't remove this #}
<input type="hidden" name="after_calculation" value="1"/>
<input type="hidden" name="zipcode" value="{{zipcode}}"/>
