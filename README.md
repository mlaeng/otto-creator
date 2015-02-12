# otto-creator
Vagrant setup for building otto modes

# To install
    git clone git@github.com:NextThingCo/otto-creator.git
    cd otto-creator
    git submodule update --init --recursive
    vagrant up
    vagrant ssh

# Usage
Once the vagrant instance is up and running and you have ssh'ed in

    cd /stak/sdk/otto-sdk
    make -j4 # change the number to however many tasks you want to run in parallel.

And the otto-sdk is built.
For instructions on building and running otto-menu and related libraries, please refer to the appropriate repository.
