{% include 'vendors.swig' %}

{{- next_js('utils.js') }}
{%- if theme.motion.enable %}
  {{- next_js('motion.js') }}
{%- endif %}

{%- set scheme_script = 'schemes/' + theme.scheme | lower + '.swig' %}
{% include scheme_script %}

{{- next_js('next-boot.js') }}
{%- if theme.bookmark.enable %}
  {{- next_js('bookmark.js') }}
{%- endif %}
{%- if theme.pjax %}
  {% include 'pjax.swig' %}
{%- endif %}
{% include 'three.swig' %}
<script type="text/javascript">
  // console.clear();
  console.log("%c 有朋自远方来, 不亦说乎.", "background:#24272A; color:#ffffff", "");
  console.log("%c Github %c", "background:#24272A; color:#ffffff", "", "https://github.com/eelve");
</script>

