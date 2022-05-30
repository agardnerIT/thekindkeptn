```
keptn trigger delivery \
--project=fulltour \
--service=helloservice \
--image="{{ .site.image }}:{{ .site.good_version }}" \
--labels=image="{{ .site.image }}",version="{{ .site.good_version }}"
```
