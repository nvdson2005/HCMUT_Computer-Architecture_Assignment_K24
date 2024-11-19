#include <iostream>
#include <fstream>

using namespace std;
int main() {
    //Open file for reading in binary mode
    ifstream binFile("INT2.BIN", ios::binary);
    if (!binFile) {
        std::cerr << "Can not open file to read" << std::endl;
        return 1;
    }

    // Read two numbers from the file to firstNum and secNum
    int firstNum, secNum;
    binFile.read(reinterpret_cast<char*>(&firstNum), sizeof(firstNum));
    binFile.read(reinterpret_cast<char*>(&secNum), sizeof(secNum));

    //Close the file
    binFile.close();

    //Print out two binary numbers
    std::cout << "The first number: " << firstNum << std::endl;
    std::cout << "The second number: " << secNum << std::endl;

    return 0;
}