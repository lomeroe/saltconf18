{% import_yaml 'state2/defaults.yml' as state2_defaults -%}
{% from 'state2/map.jinja' import state2 with context -%}
{% set state2_settings = salt['pillar.get']('state2', default=state2_defaults, merge=True) -%}

manage_tmp_file:
  file.managed:
    - name: '{{ state2['file_location'] }}'
	- source: salt://state2/files/file.jinja
    - template: jinja
    - defaults:
        data: |
            {{ state2_settings['file_data']|indent(12) }}
