{
  description = "A collection of Nix flakes templates";

  outputs =
    { ... }:
    {
      templates = {
        python = {
          path = ./python;
          description = "Python starter kit";
        };
        go = {
          path = ./go;
          description = "Go starter kit";
        };
      };
    };
}
