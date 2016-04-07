{% from "jenkins/map.jinja" import jenkins with context %}

jenkins_user:
  user.present:
    - name: {{ jenkins.user }}
    - groups: {{ jenkins.group }}
    - system: True
    - home: {{ jenkins.home }}
    - shell: /bin/bash
  {% if jenkins.home_group != 'jenkins' %}
   file.directory:
     - name: {{ jenkins.home }}
     - group: {{ jenkins.home_group }}
  {% endif %}


jenkins:
  {% if grains['os_family'] in ['RedHat', 'Debian'] %}
  pkgrepo.managed:
    - humanname: Jenkins upstream package repository
    {% if grains['os_family'] == 'RedHat' %}
    - baseurl: http://pkg.jenkins-ci.org/redhat
    - gpgkey: http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
    {% elif grains['os_family'] == 'Debian' %}
    - file: {{jenkins.deb_apt_source}}
    - name: deb http://pkg.jenkins-ci.org/debian binary/
    - key_url: http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key
    {% endif %}
    - require_in:
      - pkg: jenkins
  {% endif %}
  pkg.installed:
    - pkgs: {{ jenkins.pkgs|json }}
  service.running:
    - enable: True
    - watch:
      - pkg: jenkins
