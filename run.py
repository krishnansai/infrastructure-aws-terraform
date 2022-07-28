import os

os.system("figlet SAG TASK")
print()
print("Create Infrastructure : 1")
print("Destroy Infrastructure : 2")
print("Start : 3")
print("Stop : 4")
print()
print("cancel press : 'ctrl+c'")
print()
num=int(input("Enter the number : "))

if(num==1):
    os.system("terraform init")
    os.system("terraform apply")
    print("run it")
elif(num==2):
    os.system("terraform destroy")
    print("destroy It")
elif(num==3):
    print("under construction")
elif(num==4):
    print("under construction")
else:
    print("check the input")

