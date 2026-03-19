// Type stubs for nixvim's lib extensions.
// https://nix-community.github.io/nixvim/lib/nixvim/utils/index.html
// https://nix-community.github.io/nixvim/lib/nixvim/lua/index.html

interface NixvimUtils {
  /** Write `lua` as a raw Lua expression in the final config. Equivalent to `{ __raw = "..."; }`. */
  mkRaw: (lua: string) => { __raw: string };
  /** Transform a list into an "unkeyed" attrset, enabling mixed Lua table/list syntax. */
  listToUnkeyedAttrs: (list: any[]) => Record<string, any>;
  /** `true` normally; `false` inside `build.test`. Use to disable plugins that can't run in tests. */
  enableExceptInTests: boolean;
  /** An empty Lua table `{}`. Equivalent to `{ __empty = {}; }`. */
  emptyTable: Record<string, any>;
  /** Convert attrset keys to raw Lua keys, e.g. `{ foo = 1 }` → `{ __rawKey__foo = 1 }` → `{[foo] = 1}`. */
  toRawKeys: (attrs: Record<string, any>) => Record<string, any>;
  /** Create a one-element attrset with a raw Lua key: `mkRawKey "foo" 1` → `{ __rawKey__foo = 1 }`. */
  mkRawKey: (n: string) => (v: any) => Record<string, any>;
}

interface NixvimLuaLib {
  /** Serialise any Nix value as a Lua object string. */
  toLuaObject: (value: any) => string;
}

/** Shape of `lib.nixvim`: utils functions available both directly and under `.utils`. */
interface NixvimLibExtension extends NixvimUtils {
  utils: NixvimUtils;
  lua: NixvimLuaLib;
}

/**
 * Use this instead of `Lib` in `# @ts:` annotations for nixvim modules.
 * `Lib` is a `type` alias (not an `interface`) in nixpkgs.d.ts, so it can't
 * be merged — this intersection type adds the `nixvim` namespace on top.
 *
 * @example
 * # @ts: { pkgs: Nixpkgs; lib: NixvimLib; [key: string]: any }
 * { pkgs, lib, ... }:
 */
type NixvimLib = Lib & { nixvim: NixvimLibExtension };
