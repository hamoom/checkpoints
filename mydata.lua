-- used for handling global data

local M = {score=0, bestScore=0, filename="scorefile.txt"}

function M.setBestScore( )
	if M.score > M.getBestScore( ) then
		local path = system.pathForFile( M.filename, system.DocumentsDirectory)
	    local file = io.open(path, "w")
	    if file then
	        local contents = tostring( M.score )
	        file:write( contents )
	        io.close( file )
	        return true
	    else
	    	print("Error: could not read ", M.filename, ".")
	        return false
	    end
	end
end


function M.getBestScore()
    local path = system.pathForFile( M.filename, system.DocumentsDirectory)
    local contents = ""
    local file = io.open( path, "r" )
    if file then
         -- read all contents of file into a string
         local contents = file:read( "*a" )
         local score = tonumber(contents);
         io.close( file )
         return score
    end
    return 0
end

return M