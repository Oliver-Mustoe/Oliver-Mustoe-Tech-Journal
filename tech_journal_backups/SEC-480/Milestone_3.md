This page journals content related to NET/SEC/SYS-480 milestone 3.

**Table of contents**

- [vCenter install]((#vcenter-install))

- [Database setup](#database-setup)

- [Reflection](#reflection-for-milestone-3)

- [Sources](#sources)

## VM Inventory

- [vcenter](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/VM-Inventory/vcenter.md)

## vCenter install

Firstly I adjusted my xubuntu-wan box to point towards the VMware-VCSA iso I downloaded earlier (ESXi host client > sidebar > Edit settings > CD/DVD Drive):

![image108](https://user-images.githubusercontent.com/71083461/215294866-1d00cb78-9135-4d61-890c-03ab9b4d51de.gif)

Then, on my xubuntu-wan box, the iso will appear. I then right clicked > Mount Volume > entered password:

![image110](https://user-images.githubusercontent.com/71083461/215294868-e4a077c1-1c4c-422c-b6b4-17e2bee686a7.gif)

I then, from a terminal window, moved into the folder “/media/olivermustoe/VMware VCSA/vcsa-ui-installer/lin64” and ran the installer with `./installer`:

![image112](https://user-images.githubusercontent.com/71083461/215294870-c862ae19-e8bb-485a-8a6f-7d4968ecd93a.gif)

(causes the following to appear after entering the installer)

![image114](https://user-images.githubusercontent.com/71083461/215294872-7511f017-d897-42f0-bdd6-d2ced2e40ff0.gif)

(Now is a good time to double check that Milestone 2 worked with a double check of DNS)

![image116](https://user-images.githubusercontent.com/71083461/215294874-771cd2a0-789b-4a1c-b5a2-94f29a0eaa09.gif)

I then followed these steps to install **(STEPS RELATE TO NUMBER IN SETUP WIZARD)**:

0. Press install

![image118](https://user-images.githubusercontent.com/71083461/215294876-b36f6dd6-1044-4000-b0d1-ba18fb0edb81.gif)

1. Introduction: Next

2. End user license agreement: Check agree and next

3. Entered the following IP address information/my sign in for my ESXi host (IP is my ESXi host, accepted the certificate warning)

![image120](https://user-images.githubusercontent.com/71083461/215294878-6a10fd54-1feb-4b31-9856-0e906d1fef5a.gif)

4. Set the following VM name/root password (**RECORDED THIS)**

![image122](https://user-images.githubusercontent.com/71083461/215294880-18031673-cf1d-420d-ac3f-62c692ef899a.gif)

5. Kept the default deployment size:

![image124](https://user-images.githubusercontent.com/71083461/215294882-8ca93948-8b48-4470-a848-e8940430b347.gif)

6. Set the storage location to datastore1, enabled thin provisioning

![image126](https://user-images.githubusercontent.com/71083461/215294884-dad6a221-fb5f-4109-b9db-1484913ea582.gif)

7. Setup the following network settings:

![image128](https://user-images.githubusercontent.com/71083461/215294886-495d7c6e-f081-43e0-aead-3a0fe578a3b1.gif)

8. Double checked that the settings were completed and pressed finish:

![image130](https://user-images.githubusercontent.com/71083461/215294888-5da22817-2e17-40c6-90e0-3227ba752d55.gif)

I then waited for the installer to run and complete stage 1.  

When it was finished, the following appeared:

![image132](https://user-images.githubusercontent.com/71083461/215294890-56814e02-b63c-423a-aaab-3b43da4de85f.gif)

I would press continue, and follow these steps (STEPS RELATE TO NUMBER IN SETUP WIZARD):

1. Introduction: Next

2. Set the NTP servers

![image134](https://user-images.githubusercontent.com/71083461/215294892-2cff2caf-f8d6-4d07-b060-bacb33abeb0b.gif)

3. Then I set the following SSO configuration (same pass as before:

![image136](https://user-images.githubusercontent.com/71083461/215294895-499f6726-dd51-4920-a065-ddc71073bc34.gif)

4. Unchecked the box

![image138](https://user-images.githubusercontent.com/71083461/215294898-277d0fb1-7ced-46d0-b52d-1c5019e02d18.gif)

5. Reviewed and pressed finish and ok at the warning

![image140](https://user-images.githubusercontent.com/71083461/215294900-f1353033-e141-4c66-a8b1-cba7df0e17d4.gif)

This would commence an installer. I would wait for it to run, when it did, I was met with the following:

![image142](https://user-images.githubusercontent.com/71083461/215294902-407625dc-5542-470e-8221-4df56f2642d5.gif)

I was then able to access my vsphere installation by going to “[https://vcenter.oliver.local](https://vcenter.oliver.local)” , logging in with "administrator@.vsphere.local" and the administrator password let above:

![image144](https://user-images.githubusercontent.com/71083461/215294904-126a09d1-2488-43e9-9e51-7a3a15e77c8e.gif)

## Database setup

Once logged into vsphere, should saw the following:

![image146](https://user-images.githubusercontent.com/71083461/215294906-58746eab-98b8-4d7c-9d7d-605810b89daa.gif)

I then created a new datastore with the following settings (navigate by right clicking vcenter.oliver.local > New Datacenter…):

![image148](https://user-images.githubusercontent.com/71083461/215294908-3ab42438-c9f8-47f7-995a-579f997b67ab.gif)

**Definitions:**

Datacenter = Container for ESXi hosts, or clusters of hosts

I then added a host to my datastore by following the below steps (navigate to install by right clicking “480-Devops > Add Host…)

1. Set the following IP to lookup

![image150](https://user-images.githubusercontent.com/71083461/215294910-ab030014-323e-41fd-9275-e49007f5cda4.gif)

2. Entered my username and password for root on the ESXi host (ok’d the popup)

![image152](https://user-images.githubusercontent.com/71083461/215294912-2d545984-0e63-492e-a89a-db04f020adcc.gif)

3. Double checked my Host summary:

![image154](https://user-images.githubusercontent.com/71083461/215294914-8d5d0b0c-be18-49cd-95e0-cb57e68883d8.gif)

4. Left the license screen on default settings (just clicked next)

5. Left the Lockdown mode screen to defaults (just clicked next)

6. Left the VM location screen to defaults (just clicked next)

7. Reviewed my settings and finished:

![image156](https://user-images.githubusercontent.com/71083461/215294916-1bdd0d21-189a-4e6c-9e94-25cbb131a690.gif)

With this set, the following should appear:

![image158](https://user-images.githubusercontent.com/71083461/215294918-f85a7f29-7947-4198-9363-c026c7019556.gif)

(Believe that the yellow triangle is just due to the issue shown in the alarm raised, tested out going to one of my 480-fw VM and it did not cause any issues!)

## Reflection for Milestone 3:

The installation process of vCenter was actually much easier than I was expecting it to be (thanks VMware.) It mostly was just making sure that I was setting the right settings/doing my checks and balances. This milestone did give me a very surreal moment as I have logged into cyber.locals vCenter many times, but to log into my own domains was a really wacky feeling. My ESXi host does currently have a yellow triangle on the icon, which is worrying, but from research it appears to be from the alarm about the potential CVE. From the instructor video, it would seem that we are updating the system later so I don't believe I should be concerned about this. Overall, this milestone was a nice compliment to milestone 2 and I can’t wait to continue!

## Sources:

- [HOW TO: Suppress Configuration Issues and Warnings Alert displayed in Summary status for ESXi 6.7 after enabling SSH or ESXi Shell. | Experts Exchange](https://www.experts-exchange.com/articles/33850/HOW-TO-Suppress-Configuration-Issues-and-Warnings-Alert-displayed-in-Summary-status-for-ESXi-6-7-after-enabling-SSH-or-ESXi-Shell.html)

- https://communities.vmware.com/t5/ESXi-Discussions/Why-vsphere-cluster-hosts-have-yellow-triangles/td-p/1735194?attachment-id=79048

- [Reddit - Dive into anything](https://www.reddit.com/r/vmware/comments/yt4srt/vcsa_70u3_yellow_warning_triangle_next_to_one/)

****

Can't find something? Look in the backup [Milestone 3](https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/blob/main/tech_journal_backups/SEC-480/Milestone_2.md) page
