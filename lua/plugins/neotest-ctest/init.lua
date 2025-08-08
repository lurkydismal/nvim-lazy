if true then
    return {}
end

local lib = require("neotest.lib")

return {
    name = "neotest-ctest",

    -- Only recognize test files in your structure
    is_test_file = function(file_path)
        return file_path:match("tests/.+/src/.+%.c[p]?$")
    end,

    -- Parse test positions (TEST(testName) {...})
    discover_positions = function(path)
        return lib.discover.positions(path, {
            -- Match: TEST(testName) {
            -- This is a basic pattern and can be refined.
            position_id = "test",
            type = "test",
            pattern = "TEST%(([%w_]+)%)%s*{",
        })
    end,

    -- Build command to run tests
    build_spec = function(args)
        local test_names = {}
        for _, pos in ipairs(args.tree:to_list()) do
            if pos.type == "test" then
                table.insert(test_names, pos.name)
            end
        end

        local project_root = args.tree:data().path:match("(.*/tests/[^/]+/)") or "."
        local exe_path = project_root .. "out/main.out_test"

        return {
            command = exe_path,
            args = test_names,
            context = {
                test_names = test_names,
            },
        }
    end,

    -- Parse output from test executable
    results = function(spec, result, tree)
        local output = result.output
        local results = {}

        for _, name in ipairs(spec.context.test_names) do
            local pattern_pass = "%[PASSED%]%s+" .. name
            local pattern_fail = "%[FAILED%]%s+" .. name

            if output:match(pattern_pass) then
                results[name] = {
                    status = "passed",
                    short = "[PASSED] " .. name,
                    output = output,
                }
            elseif output:match(pattern_fail) then
                results[name] = {
                    status = "failed",
                    short = "[FAILED] " .. name,
                    output = output,
                }
            else
                -- If not explicitly matched, assume it was not run or failed silently
                results[name] = {
                    status = "failed",
                    short = "[MISSING] " .. name,
                    output = output,
                }
            end
        end

        return results
    end,
}
