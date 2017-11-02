{% from "varnish/map.jinja" import varnish with context -%}


include:
  - varnish


{% if salt['grains.get']('os_family') == 'Debian' -%}
varnish_repo_curl:
  pkg.installed:
    - name: curl


varnish_repo:
  # Import varnish repo GPG key
  cmd.run:
    - name: /usr/bin/curl https://packagecloud.io/varnishcache/varnish30/gpgkey | sudo apt-key add -
    - unless: /usr/bin/apt-key adv --list-key EE2C594C
    - require:
      - pkg: varnish_repo_curl
# NOTE: pkgrepo state module requires "require_in" in order to play nice with
# the pkg state module.
  pkgrepo.managed:
    - name: deb https://packagecloud.io/varnishcache/varnish30/debian/ {{ salt['grains.get']('oscodename')}} main
    - file: /etc/apt/sources.list.d/varnishcache_varnish30.list
    - require:
      - cmd: varnish_repo
    - require_in:
      - pkg: varnish


{% elif salt['grains.get']('os_family') == 'RedHat' -%}
  {% for component in varnish.repo.components %}
varnish_repo_{{ component }}:
  pkgrepo.managed:
    - name: varnish
    - humanname: Varnish for Enterprise Linux el{{ salt['grains.get']('osmajorrelease') }} - $basearch
    - baseurl: https://packagecloud.io/varnishcache/varnish30/el{{ salt['grains.get']('osmajorrelease') }}/$basearch
    - gpgcheck: 0
    - require_in:
      - pkg: varnish
  {% endfor %}
{%- endif %}
