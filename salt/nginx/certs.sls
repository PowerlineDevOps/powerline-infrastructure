{% set project = salt['pillar.get']('civix:project') %}
{% set user = salt['pillar.get']('civix:user') %}
{% set certs_dir = salt['pillar.get']('civix:certs_dir') %}
{% set env = salt['pillar.get']('civix:environment') %}
{% set cert_name = salt['pillar.get']('civix:cert_name') %}

# This certs should be picked up from s3 ext pillar
nginx-deploy-server-key:
  file.managed:
    - name: {{certs_dir}}/{{ project }}-server.key
    - source: salt://{{ env }}/certs/{{ cert_name }}.key
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644

nginx-deploy-server-crt:
  file.managed:
    - name: {{certs_dir}}/{{ project }}-server.crt
    - source: salt://{{ env }}/certs/{{ cert_name }}.crt
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644

# Using listen to trigger a restart if and only if the config
# runs were successful AND with changes. Since both would change
# listen should punt to the end of the run for the restart
restart-nginx-for-certs:
  service.running:
    - name: nginx
    - onchanges:
      - file: nginx-deploy-server-crt
      - file: nginx-deploy-server-key
