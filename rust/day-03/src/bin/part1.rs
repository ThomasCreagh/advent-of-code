// IMPLEMENTATION BY chris biscardi
// just trying to learn more about run by doing..

use std::{collections::BTreeMap, fs};

#[derive(Debug)]
enum Cell {
    Symbol(char),
    Empty,
    Number(u32),
}

fn main() {
    let file_path = "input1.txt";
    let input = fs::read_to_string(file_path).unwrap();
    println!("{}", part1(&input));
}

fn part1(input: &str) -> String {
    let map = input
        .lines()
        .enumerate()
        .flat_map(|(y, line)| {
            line.chars().enumerate().map(move |(x, character)| {
                (
                    (y as i32, x as i32),
                    match character {
                        '.' => Cell::Empty,
                        c if c.is_ascii_digit() => {
                            Cell::Number(c.to_digit(10).expect("should be a number"))
                        }
                        c => Cell::Symbol(c),
                    },
                )
            })
        })
        .collect::<BTreeMap<(i32, i32), Cell>>();

    let mut numbers: Vec<Vec<((i32, i32), u32)>> = vec![];
    for ((y, x), value) in map.iter() {
        if let Cell::Number(num) = value {
            match numbers.iter().last() {
                Some(v) => {
                    let last_num = v.iter().last();
                    match last_num {
                        Some(((last_num_x, _), _)) => {
                            if last_num_x + 1 == *x {
                                let last = numbers.iter_mut().last().expect("should exist");
                                last.push(((*x, *y), *num));
                            } else {
                                numbers.push(vec![((*x, *y), *num)]);
                            }
                        }
                        None => unimplemented!("shouldn't happen"),
                    }
                }
                None => {
                    numbers.push(vec![((*x, *y), *num)]);
                }
            }
        }
    }

    // map: entire grid
    // numbers: sequential numbers
    let mut sum = 0;
    for num_list in numbers {
        // (x,y)
        let positions = [
            (1, 0),
            (1, -1),
            (0, -1),
            (-1, -1),
            (-1, 0),
            (-1, 1),
            (0, 1),
            (1, 1),
        ];
        let num_positions: Vec<(i32, i32)> = num_list.iter().map(|((y, x), _)| (*x, *y)).collect();
        let pos_to_check: Vec<(i32, i32)> = num_list
            .iter()
            .flat_map(|(pos, _)| {
                positions.iter().map(|outer_pos| {
                    // outer_pos.x + pos.x, .y + .y
                    (outer_pos.0 + pos.1, outer_pos.1 + pos.0)
                })
            })
            .unique()
            .filter(|num| !num_positions.contains(num))
            .collect();

        // dbg!(pos_to_check.len(), pos_to_check);
        let is_part_number = pos_to_check.iter().any(|pos| {
            let value = map.get(pos);
            #[allow(clippy::match_like_matches_macro)]
            if let Some(Cell::Symbol(_)) = value {
                true
            } else {
                false
            }
        });

        if is_part_number {
            sum += num_list
                .iter()
                .map(|(_, num)| num.to_string())
                .collect::<String>()
                .parse::<u32>()
                .unwrap()
        }
    }

    sum.to_string()
}

#[cfg(test)]
mod test {
    #[test]
    fn given_io() {
        use super::*;

        let input = "467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..";
        let result = part1(input);
        assert_eq!("4361", result)
    }
}
