# Quota ii

> _Author_ Joshua Lay _<me@joshualay.net>_

## About
Quotaii is very simple usage monitoring app for iiNet customers. 

The intention for this project is to make a simple usage application and have a use case for [iiVolumeUsageAPI](https://github.com/joshualay/iiVolumeUsageAPI "iiVolumeUsageAPI"). 

## In progress
This is still being developed :)

## Design

### Account 
#### AccountProvider
This class is the point of contact for the application for storing and retreiving the users account information. Currently I do not store the account information. 

#### AccountDetails
Simple container class to hold readonly details for account information. It will be passed in and out of the AccountProvider to provide a common object model. 

#### AccountDetailsViewController
This is the view that we use to initiate getting account information from our user. It's very simple as it has a delegate which implements the protocol: *AccountDetailsViewControllerDelegate*. This design allows us to pass account information gathered from the view to any other class. 

In this implementation our MasterViewController implements this protocol and acts as this classes delegate. 

Now we have a quick an easy way to attach this AccountViewController to any class of our choosing. 

### Getting the usage
#### MasterViewController
Our starting point. 

*Account information retrieval*
Using our *AccountProvider* we first check if we have any user details stored. If we don't we present the *AccountDetailsViewController* view. MasterViewController implements *AccountDetailsViewControllerDelegate*, so once the user has finished entering in their details the delegate method will be called. 

We store the details in account provider and attempt to get the usage again. 


*Volume usage retrieval*
MasterViewController implements *iiVolumeUsageProviderDelegate* protocol. This protocol will ask the delegate to provide the username and password. We're able to do this via our *AccountProvider* property. 

Once we've sucessfully retrieved the volume usage we display it. 

### Ramblings
I wanted really wanted to explore how protocol's benefits my application design. This is why there's a protocol for the AccountDetailsViewController and in the iiVolumeUsageProvider. 

I can change how the account information is stored and retrieved without affecting anything as long as I leave the protocol alone. 