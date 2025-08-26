#!/bin/bash

as -o main.o main.s
as -o display.o display.s
as -o read.o read.s
ld -o shell main.o display.o read.o
