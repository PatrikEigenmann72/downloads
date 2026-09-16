# enigma

```text
NAME:
      enigma - Version: 01.04

SYNOPSIS:
      enigma [ -e "plaintext" | filename ]
      enigma [ -d "ciphertext" | filename ]
      enigma [--debug[:level]] [--keywords:csv]
      enigma [-h | -H | -help | -Help | -?] [--version]


DESCRIPTION:
      enigma - This tool is a modern C implementation inspired by the Enigma 
      machine ΓÇö the cipher device used throughout the early and mid - 20th 
      century to secure commercial, diplomatic, and military communication. 
      Enigma was deployed extensively by Nazi Germany during World War II and 
      was trusted to protect the most sensitive messages.

      The first major breakthroughs against Enigma came in 1932 from Polish 
      cryptologists Marian Rejewski, Jerzy R├│┼╝ycki, and Henryk Zygalski, 
      whose work laid the mathematical foundation for all later Allied 
      cryptanalysis. In July 1939, Polish intelligence shared their methods 
      and reconstructed machines with French and British representatives, 
      enabling the larger wartime codebreaking effort.

      At Bletchley Park, Alan Turing and his colleagues expanded on this 
      foundation, developing new techniques and electromechanical systems 
      to handle the enormous volume of encrypted traffic. Turings 
      contributions were central to the success of the Enigma - breaking 
      effort and to the birth of modern computing. His later persecution 
      for his homosexuality ΓÇö culminating in his death in 1954 ΓÇö remains 
      one of the most tragic injustices in the history of science.

      This project is not a replica of the historical Enigma. It is a 
      personal interpretation: a rotor-based cipher engine inspired by 
      the mechanical principles of the original, but redesigned with a 
      modern, extended alphabet and a unique stepping cadence. Each 
      rotor includes a subtle tribute at positions 27 and 28 ΓÇö the 
      initials of musicians from the ΓÇ£Club 27,ΓÇ¥ a nod to brilliant 
      lives cut short.

      The purpose of this tool is both technical and human. Building it 
      was an exploration of reversible cipher design, but also a 
      confrontation with the history behind the machine: the brilliance of 
      those who broke it, the cruelty of the systems that punished them, 
      and the uncomfortable truth that technological progress does not 
      guarantee moral progress. This project exists to honor that history 
      and to acknowledge the human cost behind the mathematics.


OPTIONS:
      -e ["plaintext" | file]
         Encrypts a quoted string or the full contents of a plaintext 
         file. This is the forward path through the EnigmaΓÇæinspired 
         engine. The result is emitted to stdout.

      -d ["ciphertext" | file]
         Decrypts ciphertext created by this tool. Accepts inline 
         encrypted text or a file containing it. The engine retraces 
         the exact rotor sequence used during encryption and restores 
         the original plaintext with full fidelity.

      Output redirection:
         Use '>' to write the result to a file, or '>>' to append to an
         existing file. For example:
            enigma -e "Hello" > secret.txt
            enigma -d secret.txt >> log.txt

      --debug, --debug:<level>, --debug=<level>
         Enables enigma's own runtime diagnostic output. --debug alone shows 
         everything; --debug:<level> narrows it to verbose, info, warn, error, 
         or all. Either : or = works.

      --keywords:<csv>, --keywords=<csv>
         Narrows enigma's own diagnostic output (see --debug above) to lines 
         tagged with one of the given comma-separated keywords. Either : or = 
         works.

      -h, -H, -help, -Help, -?
         Do you need help? Any of these flags will open the application's 
         manpage. This UNIX-style help file, familiar to developers and 
         system administrators, is integrated into enigma itself. The 
         beauty of this approach is that anyone working on macOS, BSD, UNIX, 
         or Linux will instantly feel at home with the layout. Think of it as 
         your built-in guide whenever you need more insight into the program 
         enigma.

      --version
         Prints the tool's identity block and exits.


LICENSE:
      Copyright 2024 Free Software Foundation, Inc. License GPLv3+: GNU GPL version 3
      or later <https://gnu.org/licenses/gpl.html>. This is free software: you are free
      to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
```
