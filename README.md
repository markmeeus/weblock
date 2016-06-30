# Weblock

Experimental work in progress.


```
#Lock a resource
curl http://localhost:4001/lock/some_resource_key?timeout=5&lease=30000
#timeout and lease not implemented yet
```

```
#unlock
curl -X DELETE http://localhost:4001/lock/some_resource_key/{lock_id}
```
