```
keptn trigger delivery \
--project=fulltour \
--service=helloservice \
--image="{{ .site.image }}:{{ .site.slow_version }}" \
--labels=image="{{ .site.image }}",version="{{ .site.slow_version }}"
```
