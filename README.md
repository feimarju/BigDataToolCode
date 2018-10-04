
### BigDataToolCode
  
The following are the very basic steps that can be done from the terminal.

#### Clone the repo

How to clone the **BigDataToolCode** GitHub repo.

1. Open the terminal and create a local folder in your computer where to store this repo.  
2. Clone the repo **git clone** https://github.com/joseluisrojo/BigDataToolCode **-b development_JL**  
Note that I am assuming I will work with my own branch. Read more next.

#### Branches and how to create your self branch

Note that above you have cloned the development branch. We will work with:  
a) A master branch.  
b) A development branch.  
c) Your own branch, where it is better wo work. 
You should create and work in your self branch if you are going to reuse or modify the code. Your team would decide who will merge the development branch to the master branch, and how to merge the individual branches with the development branch.

In order to create a branch, the fastes way is going to GitHub and create it there.  
In addition, you can work on the terminal and then **git checkout -b NombreDeLaRama**  
An alternative way is start with **git branch NombreDeLaRama** and then **git checkout NombreDeLaRama**

#### How to update your branch

Go to the GIT folder.  
**git pull -b development_JL**   
Make your stuff  
**git commit -m "My description of the changes"**  
**git push -b development_JL**  

