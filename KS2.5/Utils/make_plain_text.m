function out = make_plain_text(in)
out = regexprep(in, '[\\\^\_]','\\$0');
end