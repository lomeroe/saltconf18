{% import_yaml 'state1/defaults.yml' as state1_defaults -%}
{% from 'state1/map.jinja' import state1 with context -%}
{% set state1_settings = salt['pillar.get']('state1', default=state1_defaults, merge=True) -%}

manage_tmp_file:
  file.managed:
    - name: '{{ state1['file_location'] }}'
    - source: salt://state1/files/file.jinja
    - template: jinja
    - defaults:
        data: |
            {{ state1_settings['file_data']|indent(12) }}
