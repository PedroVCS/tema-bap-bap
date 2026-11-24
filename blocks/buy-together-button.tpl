{# Buy Together Button Block - Static block of buy-together-form #}

{% set btn_settings = block.settings %}
{% set btn_variant = btn_settings.variant | default('primary') %}
{% set btn_style = btn_variant == 'secondary' ? settings.button_secondary_style : (btn_variant == 'tertiary' ? settings.button_tertiary_style : settings.button_primary_style) %}

{# Resolve custom color overrides based on variant #}
{% if btn_variant == 'secondary' %}
	{% set custom_background = btn_settings.custom_background_color_secondary | default(settings.button_secondary_background_color) %}
	{% set custom_foreground = btn_settings.custom_text_color_secondary | default(settings.button_secondary_foreground_color) %}
{% elseif btn_variant == 'tertiary' %}
	{% set custom_background = btn_settings.custom_background_color_tertiary | default(settings.button_tertiary_background_color) %}
	{% set custom_foreground = btn_settings.custom_text_color_tertiary | default(settings.button_tertiary_foreground_color) %}
{% else %}
	{% set custom_background = btn_settings.custom_background_color | default(settings.button_primary_background_color) %}
	{% set custom_foreground = btn_settings.custom_text_color | default(settings.button_primary_foreground_color) %}
{% endif %}

{# Build inline styles - button color overrides #}
{% set btn_styles %}
	{% if custom_background and btn_style != 'underlined' %}background-color: {{ custom_background }};{% endif %}
	{% if custom_foreground %}color: {{ custom_foreground }};{% endif %}
	{% if custom_foreground and btn_style == 'outline' %}border-color: {{ custom_foreground }};{% endif %}
{% endset %}

{% set btn_classes = 'buy-together-submit btn-' ~ btn_variant ~ ' btn-medium btn-big-md' ~ (btn_style == 'underlined' ? ' btn-underlined' : '') %}

{# Add to cart CTA #}

<input
	type="submit"
	class="js-buy-together-submit btn {{ btn_classes }}"
	value="{{ button_label }}"
	{% if btn_styles | trim %}style="{{ btn_styles | trim }}"{% endif %}
	data-component="cross-sell-widget.add"
	{{ block | block_attributes }}
/>

{# Fake add to cart CTA visible during add to cart event #}

{% include 'snippets/placeholders/button-placeholder.tpl' with { settings_classes: btn_classes, settings_styles: btn_styles | trim } %}

{% schema %}
{
  "name": "t:names.buy_together_button",
  "icon": "buttons",
  "limit": 1,
  "static": true,
  "deletable": false,
  "duplicatable": false,
  "hideable": false,
  "settings": [
    {
      "type": "header",
      "content": "t:settings.style"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "variant",
      "options": [
        { "value": "primary", "label": "t:settings.primary_button" },
        { "value": "secondary", "label": "t:settings.secondary_button" },
        { "value": "tertiary", "label": "t:settings.tertiary_button" }
      ],
      "default": "primary"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_background_color",
      "label": "t:settings.background",
      "default_setting": "button_primary_background_color",
      "visible_if": "{{ block.settings.variant == 'primary' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_text_color",
      "label": "t:settings.text_color",
      "default_setting": "button_primary_foreground_color",
      "visible_if": "{{ block.settings.variant == 'primary' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_background_color_secondary",
      "label": "t:settings.background",
      "default_setting": "button_secondary_background_color",
      "visible_if": "{{ block.settings.variant == 'secondary' }}",
      "disabled_if": "{{ settings.button_secondary_style == 'underlined' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_text_color_secondary",
      "label": "t:settings.text_color",
      "default_setting": "button_secondary_foreground_color",
      "visible_if": "{{ block.settings.variant == 'secondary' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_background_color_tertiary",
      "label": "t:settings.background",
      "default_setting": "button_tertiary_background_color",
      "visible_if": "{{ block.settings.variant == 'tertiary' }}",
      "disabled_if": "{{ settings.button_tertiary_style == 'underlined' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_text_color_tertiary",
      "label": "t:settings.text_color",
      "default_setting": "button_tertiary_foreground_color",
      "visible_if": "{{ block.settings.variant == 'tertiary' }}"
    }
  ]
}
{% endschema %}
