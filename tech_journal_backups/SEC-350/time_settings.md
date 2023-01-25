This page details steps for changing time settings for various operating system logs to increase verboseness.

**Table of contents**

1. Linux Based
   
   1. [Ubuntu](#ubuntu)
   
   2. [Rocky](#rocky)



# Ubuntu

For Ubuntu based hosts, commenting out the following lines in "/etc/rsyslog" makes it more verbose:  
![image](https://user-images.githubusercontent.com/71083461/214674297-462641a0-ab55-4083-818c-acb38386d185.png)

The following shows the difference the above settings makes with the same test of `logger -t test whattimeisit` (first is without setting, bottom is with it):  
![image](https://user-images.githubusercontent.com/71083461/214674396-a0c44905-f8a5-411e-8d12-82fb5950d03f.png)



# Rocky

For Rocky based hosts, commenting out the following lines in "/etc/rsyslog" makes it more verbose:  

![image](https://user-images.githubusercontent.com/71083461/214674524-0706a22d-5141-45a1-ae12-d30f19ec014d.png)  



Below shows the above setting tested (first is without setting, bottom is with it):  

![D2](https://user-images.githubusercontent.com/71083461/214675559-61885576-d346-4d7f-9697-51f84ef33d4c.PNG)


