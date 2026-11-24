{# Buy Together Section - Bundle offer for the product page #}

{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = not full_width %}
{% set gap = section.settings.gap | default(32) %}
{% set vertical_padding = section.settings.vertical_padding | default(32) %}
{% set horizontal_padding = full_width ? (section.settings.horizontal_padding | default(32)) : 0 %}
{% set background_color = section.settings.background_color | default('transparent') %}

{% set section_styles %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
{% endset %}

{% set has_offer = not is_preset_preview and buy_together_products | length > 0 %}
{% set show_sample = is_preset_preview or (is_preview and not has_offer) %}
{% if has_offer or show_sample %}
	<div
		{% if full_width %}class="section-full-width"{% endif %}
		data-store="buy-together-section"
		data-section-id="{{ section.id }}"
		{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
	>
		{% if page_width %}
			<div class="container">
		{% endif %}
			<div class="buy-together-blocks"{% if gap %} style="gap: {{ gap }}px;"{% endif %}>
				{% for block in section.blocks %}
					{% include 'blocks/' ~ block.type ~ '.tpl' with { block: block } %}
				{% endfor %}
			</div>
		{% if page_width %}
			</div>
		{% endif %}
	</div>
{% endif %}

{% schema %}
{
    "name": "t:names.buy_together",
    "icon": "DiscountCircleIcon",
    "class": "section-buy-together",
    "duplicatable": false,
    "limit": 1,
    "enabled_on": {
        "page_templates": ["product"]
    },
    "blocks": [
        { "tags": ["general"] },
        { "type": "buy-together-form", "static": true }
    ],
    "settings": [
        {
            "type": "header",
            "content": "t:names.design"
        },
        {
            "type": "setting",
            "setting_type": "radio",
            "id": "section_width",
            "label": "t:settings.section_width",
            "options": [
                { "value": "page", "label": "t:options.page" },
                { "value": "full", "label": "t:options.full" }
            ],
            "default": "page"
        },
        {
            "type": "setting",
            "setting_type": "range",
            "id": "gap",
            "label": "t:settings.gap",
            "min": 0,
            "max": 50,
            "step": 4,
            "unit": "px",
            "default": 32,
            "icon": "vertical_spacing"
        },
        {
            "type": "setting",
            "setting_type": "range",
            "id": "vertical_padding",
            "label": "t:settings.vertical_padding",
            "min": 0,
            "max": 120,
            "step": 4,
            "unit": "px",
            "default": 32,
            "icon": "vertical_padding"
        },
        {
            "type": "setting",
            "setting_type": "range",
            "id": "horizontal_padding",
            "label": "t:settings.horizontal_padding",
            "min": 0,
            "max": 120,
            "step": 4,
            "unit": "px",
            "default": 32,
            "icon": "horizontal_padding",
            "disabled_if": "{{ section.settings.section_width == 'page' }}"
        },
        {
            "type": "header",
            "content": "t:names.colors"
        },
        {
            "type": "setting",
            "setting_type": "color",
            "id": "background_color",
            "label": "t:settings.background",
            "default": "transparent"
        }
    ],
    "presets": [
        {
            "name": "t:names.buy_together",
            "settings": {
                "section_width": "page",
                "gap": 32,
                "vertical_padding": 32,
                "horizontal_padding": 32
            },
            "blocks": [
                { "type": "heading", "settings": { "title": "t:defaults.buy_together.heading", "size": "h3" } },
                {
                    "type": "buy-together-form",
                    "static": true,
                    "blocks": [
                        { "type": "buy-together-button", "static": true, "settings": { "variant": "primary" } }
                    ]
                }
            ]
        }
    ]
}
{% endschema %}
