import sys

class WumpusWorldCustom:
    def __init__(self, size):
        self.size = size
        self.grid = [['' for _ in range(size)] for _ in range(size)]
        self.agent_pos = None
        self.alive = True
        self.has_gold = False
        self.wumpus_alive = True

    def place_element(self, prompt, char):
        while True:
            try:
                print("\n--- Placing {} ---".format(prompt))
                r = int(input("Enter Row (0 to {}): ".format(self.size-1)))
                c = int(input("Enter Col (0 to {}): ".format(self.size-1)))
                if 0 <= r < self.size and 0 <= c < self.size:
                    if char == 'A':
                        self.agent_pos = [r, c]
                        return [r, c]
                    elif self.grid[r][c] == '' and [r,c] != self.agent_pos:
                        self.grid[r][c] = char
                        return [r, c]
                    else:
                        print("Square already occupied!")
                        continue
                print("Out of bounds!")
            except ValueError: print("Invalid input!")

    def get_sensors(self):
        r, c = self.agent_pos
        sensors = []
        for dr, dc in [(-1,0), (1,0), (0,-1), (0,1), (0,0)]:
            nr, nc = r + dr, c + dc
            if 0 <= nr < self.size and 0 <= nc < self.size:
                cell = self.grid[nr][nc]
                if 'G' in cell: sensors.append("GLITTER (Gold nearby/here)")
                if 'W' in cell and self.wumpus_alive: sensors.append("STENCH (Wumpus nearby/here)")
                if 'P' in cell: sensors.append("BREEZE (Pit nearby/here)")
        return list(set(sensors))

    def print_display(self):
        print("\n" + "="*10 + " MATRIX " + "="*10)
        header = "    " + "   ".join(["C{}".format(i) for i in range(self.size)])
        print(header)
        for r in range(self.size):
            row_str = "R{} |".format(r)
            for c in range(self.size):
                cell = "A" if [r, c] == self.agent_pos else self.grid[r][c]
                row_str += cell.center(4) + "|"
            print(row_str)
        print("\nSENSE DETAILS:")
        sensors = self.get_sensors()
        if sensors:
            for s in sensors: print(" >> " + s)
        else: print(" >> None")
        print("="*28)

    def move(self, d):
        move_map = {'u': [-1,0], 'd': [1,0], 'l': [0,-1], 'r': [0,1]}
        if d not in move_map: return "Invalid!"
        nr, nc = self.agent_pos[0] + move_map[d][0], self.agent_pos[1] + move_map[d][1]
        if 0 <= nr < self.size and 0 <= nc < self.size:
            self.agent_pos = [nr, nc]
            curr = self.grid[nr][nc]
            if curr == 'W': self.alive = False; return "DEATH: Wumpus"
            if curr == 'P': self.alive = False; return "DEATH: Pit"
            if curr == 'G': self.has_gold = True; return "WIN"
            return "MOVED"
        return "WALL"

def main():
    n = int(input("Grid Size: "))
    game = WumpusWorldCustom(n)
    game.place_element("Agent", 'A')
    game.place_element("Wumpus", 'W')
    game.place_element("Gold", 'G')
    num_pits = int(input("Pits: "))
    for i in range(num_pits): game.place_element("Pit", 'P')

    while game.alive:
        game.print_display()
        cmd = input("Move (u/d/l/r): ").lower().strip()
        result = game.move(cmd)

        if result == "WIN":
            game.print_display()
            print("\nWIN: Reached Gold! Game Ending...")
            sys.exit()
        elif "DEATH" in result:
            game.print_display()
            print("\n" + result)
            sys.exit()
        else:
            print(result)

if __name__ == "__main__":
    main()
