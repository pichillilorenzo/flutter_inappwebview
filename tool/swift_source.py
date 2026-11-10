"""Extract complete Swift blocks for the native production-code harnesses.

This is a lexical boundary finder, not a Swift syntax/type checker. It skips
ordinary, multiline and raw string literals (including interpolation), line
comments and nested block comments before matching code braces. The real Swift
compiler and Apple SDK checks remain responsible for language/API correctness.
"""

import re


_STRING_START = re.compile(r'(#+)?("""|")')


def _skip_literal_or_comment(source, index):
    if source.startswith('//', index):
        end = source.find('\n', index + 2)
        return len(source) if end == -1 else end + 1
    if source.startswith('/*', index):
        depth = 1
        end = index + 2
        while end < len(source):
            if source.startswith('/*', end):
                depth += 1
                end += 2
            elif source.startswith('*/', end):
                depth -= 1
                end += 2
                if depth == 0:
                    return end
            else:
                end += 1
        raise ValueError(f'Unterminated Swift block comment at offset {index}')

    match = _STRING_START.match(source, index)
    if match is None:
        return None
    hashes, quotes = match.group(1) or '', match.group(2)
    closing = quotes + hashes
    escape = '\\' + hashes
    end = match.end()
    while end < len(source):
        if source.startswith(closing, end):
            return end + len(closing)
        if source.startswith(escape, end):
            escaped = end + len(escape)
            if source.startswith('(', escaped):
                end = _balanced_end(source, escaped, '(', ')')
            else:
                end = escaped + 1
        else:
            if quotes == '"' and source[end] in '\r\n':
                raise ValueError(f'Unterminated Swift string at offset {index}')
            end += 1
    raise ValueError(f'Unterminated Swift string at offset {index}')


def _balanced_end(source, opening, left, right):
    depth = 1
    index = opening + 1
    while index < len(source):
        skipped = _skip_literal_or_comment(source, index)
        if skipped is not None:
            index = skipped
            continue
        if source[index] == left:
            depth += 1
        elif source[index] == right:
            depth -= 1
            if depth == 0:
                return index + 1
        index += 1
    raise ValueError(f'Unterminated Swift {left}{right} block at offset {opening}')


def extract_swift_block(source, signature):
    """Return the complete braced declaration/closure at a unique signature.

    Preserve source text verbatim, without relying on indentation. Missing or
    ambiguous signatures and unterminated constructs fail instead of returning
    a partial block that could silently reduce the native test's coverage.
    """
    start = source.index(signature)
    if source.find(signature, start + len(signature)) != -1:
        raise ValueError(f'Ambiguous Swift signature: {signature!r}')
    index = start
    while index < len(source):
        skipped = _skip_literal_or_comment(source, index)
        if skipped is not None:
            index = skipped
            continue
        if source[index] == '(':
            # A default argument may itself contain a braced closure.
            index = _balanced_end(source, index, '(', ')')
            continue
        if source[index] == '{':
            return source[start:_balanced_end(source, index, '{', '}')]
        index += 1
    raise ValueError(f'No Swift block after signature: {signature!r}')
