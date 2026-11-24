{#
  Alert
  Alert message (success, danger, warning, etc.).
#}
<div class="alert alert-{{ type }} {{ class }}" {% if data_component %}data-component="{{ data_component }}"{% endif %}>
    {{ message }}
</div>
