# otto-creator
Vagrant setup for building otto modes

# Installation
    git clone git@github.com:NextThingCo/otto-creator.git
    cd otto-creator    	
	./fetch-modes.sh # Fetch the SDK, menu, and GIF mode
	
## Start the VM
    vagrant up
    vagrant ssh

# Usage
Once the vagrant instance is up and running and you have ssh'ed in

    cd /stak/sdk/otto-runner
    make -j4 # change the number to however many tasks you want to run in parallel.

And the otto-runner is built.

For instructions on building and running otto-menu and related libraries, please refer to the appropriate repository.
