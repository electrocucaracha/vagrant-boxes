module.exports = {
  extends: ["@commitlint/config-conventional"],
  ignores: [(message) => message === "Initial commit"],
};
