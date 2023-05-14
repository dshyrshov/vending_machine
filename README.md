## Vending Machine

A simple vending machine emulator. Takes input of items from `init_values.yml` file.
Keeps track of the available inventory, you can order items that are in stock only.
Keeps track of available coins in the till, which are also initialized from `init_values.yml`. If change can't be provided it'll return coins already slotted by the user. 

Finds the best possible way to return change using minimum amount of coins from the available coins in the till. The coins used in the initialize values allow to use greedy algorithm of finding coin change. Dynamic programming approach is also implemented in case the requirements change.

## Usage

Run `bundle install` to install necessary gems for tests.
Make sure that ruby `3.2.0` is installed although any version above 3 should be fine too.
Run `./start.rb` to run the program.
Run `bundle exec rspec spec` to execute tests.
