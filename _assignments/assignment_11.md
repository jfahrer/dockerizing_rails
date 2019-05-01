# Preserving history
Keeping the history for the Rails console can be useful when we want you are like me and try to replay commands. Currently the history is stored in the Container file-system and will be deleted when we delete or re-create our containers.

We can get around this by storing the history file locally on our system using a bind mount:
```
services:
  app:
    # -- SNIP --
    volumes:
      - ./:/usr/src/app
      - ${HOME}/.irbrc:/root/.irbrc
      - ${HOME}/.irb-history:/root/.irb-history
```

My `.irbrc` looks something like this:
```
require 'irb/completion'
require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-history"
```

Make sure that the history file exists:
```
touch ${HOME}/.irb-history
```

Wondering about the environment variable in the compose file? It's a thing: https://docs.docker.com/compose/environment-variables/

[Back to the overview](../README.md#assignments)
