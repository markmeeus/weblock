# Weblock

Experimental work in progress.
I'm mainly using this project to work on my elixir skills, but why not create something usefull right?

In a distributed environment, you want your servers to be like cattle, not pets. But in some scenario's you still need to have synchronization between them.

Weblock provides web-based synchronization mechanisms. 
For now, it's only lock/unlock. 

##Locking a resource
```
curl http://localhost:4001/lock/some_resource_key?timeout=5&lease=30000
```
The response will be returned as soon as the lock is obtained (or a timeout occured)

###Params:
*timeout*: The maximum number of milliseconds to wait for the lock to become available. 

*lease*:   Amount of milliseconds the lock will be kept. If the lock is not unlocked explicitly after this period, the server will unlock it automatically.

Response in case of success:
```
{
  result: "ok",
  lock_id: "bdb984b2-57ad-11e6-8742-6c4008a8c184"
}
```

Response in case of timeout:
```
{
   result: "timeout"
}
```

##unlocking a resource
A resource can be unlocked with the lock_id obtained from the GET lock result
```
curl -X DELETE http://localhost:4001/lock/some_resource_key/{lock_id}
```

Response in case of success:
```
{
   result: "unlocked"
}
```

If the lock was allready unlocked:
```
{
   result: "unknown_lock_id"
}
```
