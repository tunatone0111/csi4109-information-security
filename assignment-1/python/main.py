import sys


class Lock:
    def __init__(self, owner_name, keys):
        self.owner_name = owner_name
        self.keys = keys
        self.inside = []
        self.state = {
            "user_name": "",
            "key": "",
            "allowed": False
        }
        self.secret_key = "FIREFIGHTER_SECRET_KEY"

    def insert(self, user, key):
        self.state = {
            "user_name": user,
            "key": key,
            "allowed": False
        }
        print(f'KEY {key} INSERTED BY {user}')

    def turn(self, user):
        key = self.state["key"]
        if user == self.state["user_name"] and (key in self.keys or key == self.secret_key):
            self.state["allowed"] = True
            print(f"SUCCESS {user} TURNS KEY {key}")
        else:
            print(f"FAILURE {user} UNABLE TO TURN KEY {key}")

    def enter(self, user):
        if self.state["user_name"] == user and self.state["allowed"]:
            self.inside.append(user)
            print(f"ACCESS ALLOWED")
        else:
            print(f"ACCESS DENIED")

    def whos_inside(self):
        if len(self.inside) == 0:
            print('NOBODY HOME')
        else:
            print(*self.inside, sep=", ")

    def change_locks(self, user_name, keys):
        if user_name != self.owner_name or user_name not in self.inside:
            print("ACCESS DENIED")
        else:
            self.keys = keys
            print("OK")

    def leave(self, user):
        if user not in self.inside:
            print(f"{user} NOT HERE")
        else:
            self.inside.remove(user)
            print("OK")


if __name__ == "__main__":
    lock = Lock(sys.argv[1], sys.argv[2:])
    while True:
        try:
            user_input = input()
        except(EOFError):
            break

        if user_input.startswith("INSERT KEY"):
            user, key = user_input.split()[2:4]
            lock.insert(user, key)
        elif user_input.startswith("TURN KEY"):
            user = user_input.split()[2]
            lock.turn(user)
        elif user_input.startswith("ENTER HOUSE"):
            user = user_input.split()[2]
            lock.enter(user)
        elif user_input.startswith("WHO'S INSIDE?"):
            lock.whos_inside()
        elif user_input.startswith("CHANGE LOCKS"):
            user = user_input.split()[2]
            keys = user_input.split()[3:]
            lock.change_locks(user, keys)
        elif user_input.startswith("LEAVE HOUSE"):
            user = user_input.split()[2]
            lock.leave(user)
        else:
            print("ERROR")
