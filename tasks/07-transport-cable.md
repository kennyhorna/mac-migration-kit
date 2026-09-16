PHASE: Transfer
- [ ] Connect the Macs with a USB-C/Thunderbolt **data** cable
- [ ] Enable Remote Login on the destination Mac, restricted to your user
- [ ] Create a temporary SSH key and authorize it for the cable network only (`from="169.254.0.0/16"`)
- [ ] Verify the link: `ping` the address and open an SSH session
