import Foundation

// Enum for token types
enum TokenType {
    case startTag
    case endTag
    case text
}

// Token structure
struct Token {
    let type: TokenType
    let data: String
}

// Simple DOM Node class
class Node {
    let name: String
    var children: [Node] = []
    let isText: Bool
    
    init(name: String, isText: Bool = false) {
        self.name = name
        self.isText = isText
    }
    
    // Add a child node
    func addChild(_ child: Node) {
        children.append(child)
    }
    
    // Print the tree (for debugging)
    func printTree(depth: Int = 0) {
        let indent = String(repeating: "  ", count: depth)
        if isText {
            print("\(indent)Text: \"\(name)\"")
        } else {
            print("\(indent)<\(name)>")
        }
        for child in children {
            child.printTree(depth: depth + 1)
        }
        if !isText && depth > 0 {
            print("\(indent)</\(name)>")
        }
    }
}

// Tokenizer function
func tokenize(_ html: String) -> [Token] {
    var tokens: [Token] = []
    var pos = html.startIndex
    var buffer = ""
    
    while pos < html.endIndex {
        let c = html[pos]
        
        if c == "<" {
            // Flush any buffered text
            if !buffer.isEmpty {
                tokens.append(Token(type: .text, data: buffer))
                buffer = ""
            }
            
            // Check if it's an end tag
            let nextIndex = html.index(pos, offsetBy: 1, limitedBy: html.endIndex) ?? html.endIndex
            let isEndTag = nextIndex < html.endIndex && html[nextIndex] == "/"
            pos = html.index(pos, offsetBy: isEndTag ? 2 : 1)
            
            // Extract tag name
            var tagName = ""
            while pos < html.endIndex && html[pos] != ">" {
                tagName.append(html[pos])
                pos = html.index(pos, offsetBy: 1)
            }
            if pos < html.endIndex {
                pos = html.index(pos, offsetBy: 1) // Skip '>'
            }
            
            tokens.append(Token(type: isEndTag ? .endTag : .startTag, data: tagName))
        } else {
            // Accumulate text content
            buffer.append(c)
            pos = html.index(pos, offsetBy: 1)
        }
    }
    
    // Flush remaining text
    if !buffer.isEmpty {
        tokens.append(Token(type: .text, data: buffer))
    }
    
    return tokens
}

// Build DOM tree from tokens
func buildDOM(_ tokens: [Token]) -> Node {
    let root = Node(name: "document")
    var stack: [Node] = [root]
    
    for token in tokens {
        switch token.type {
        case .startTag:
            let node = Node(name: token.data)
            stack.last!.addChild(node)
            stack.append(node)
        case .endTag:
            if !stack.isEmpty {
                stack.removeLast()
            }
        case .text:
            let textNode = Node(name: token.data, isText: true)
            stack.last!.addChild(textNode)
        }
    }
    
    return root
}

// Main execution
let html = "<html><body><div>Hello <b>world</b></div></body></html>"

// Step 1: Tokenize
let tokens = tokenize(html)
print("Tokens:")
for token in tokens {
    let typeStr: String
    switch token.type {
    case .startTag: typeStr = "StartTag"
    case .endTag: typeStr = "EndTag"
    case .text: typeStr = "Text"
    }
    print("\(typeStr): \(token.data)")
}

// Step 2: Build DOM tree
let dom = buildDOM(tokens)

// Step 3: Print the tree
print("\nDOM Tree:")
dom.printTree()
