import sys

first_arg = sys.argv[1]
second_arg = sys.argv[2]

def greetings(word1=first_arg, word2=second_arg):
    print("{} {}".format(word1, word2))

if __name__ == "__main__":
    greetings()
    greetings("Bonjour", "monde")
