# Weblock

Work in progress.
Weblock will be a very naive http-based resource lock manager.

```
//Lock resource
POST /resource_to_lock
{timeout:5,lease:30000}

response:
{result: 'ok', lockId: 123}
```

```
//Release lock
DELETE /resource_to_lock/123
```
