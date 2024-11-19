#include<iostream>
#include<fstream>

using namespace std;

int main(){
    //The first and second number in the file goes here
    int firstNum;
    int secondNum;
    //Get the input from the user
    cout << "Enter the multiplicand: ";
    cin >> firstNum;

    cout << "Enter the multiplier: ";
    cin >> secondNum;
    //Open INT2.BIN in binary mode for editing
    ofstream binFile("INT2.BIN", ios::binary);
    if(!binFile){
        cerr << "Error opening file for writing" << endl;
        return 1;
    }

    //Write firstNum and secondNum to the file
    binFile.write(reinterpret_cast<char*>(&firstNum), sizeof(firstNum));
    binFile.write(reinterpret_cast<char*>(&secondNum), sizeof(secondNum));

    //Close the file
    binFile.close();

    cout <<"Write successful" << endl;
    return 0;
}