### AWS WEB APPLICATION FIREWALL (WAF)
- AWS WAF is a web application firewall that helps protect your web applications from common web exploits and vulnerabilities that could affect application availability, compromise security, or consume excessive resources.
- Its important for environments that host public facing web applications.
#### Threats AWS WAF protects against:
- SQL Injection: AWS WAF can detect and block SQL injection attacks, where attackers attempt to manipulate database queries by injecting malicious SQL code into input fields.
- Cross-Site Scripting (XSS): AWS WAF can identify and block XSS attacks, where attackers inject malicious scripts into web pages viewed by other users.
- HTTP Floods: AWS WAF can mitigate HTTP flood attacks, which are a type of Distributed Denial of Service (DDoS) attack that overwhelms a web application with a high volume of HTTP requests.
- Bot Traffic: AWS WAF can help identify and block unwanted bot traffic that may scrape content, perform credential stuffing attacks, or engage in other malicious activities.S leverages Kubernetes to orchestrate containerized applications across a cluster of EC2 instances or using F
- DDOS Attacks: While AWS WAF is not a DDoS protection service, it can be used in conjunction with AWS Shield to help mitigate DDoS attacks by filtering out malicious traffic before it reaches your web application. A DDOS attack aims to make a service unavailable by overwhelming it with traffic from multiple sources.
-  Pay per use abuse: AWS WAF can help prevent pay-per-use abuse by blocking requests that exhibit suspicious behavior, such as excessive API calls or resource consumption.

#### How AWS WAF works:
AWF sits in front of your web application and inspects incoming HTTP/HTTPS requests based on a set of rules that you define. These rules can be based on various criteria, such as IP addresses, HTTP headers, URI strings, and request body content. When a request matches a rule, AWS WAF takes the specified action, such as allowing, blocking, or counting the request.
- AWS WAF can be integrated with other AWS services, such as Amazon CloudFront (a content delivery network), Application Load Balancer (ALB), and API Gateway, to provide comprehensive protection for your web applications.

###$ Important concepts of AWS WAF:
- WEB ACLs (Access Control Lists): These are the core components of AWS WAF that define the rules for allowing or blocking web requests.
- Rules: Conditions defined within a Web ACL that determine whether to allow, block, captcha, or count requests based on specified criteria.
- Rule Groups: Collections of predefined rules that can be reused across multiple Web ACLs. You can create or use managed rule groups provided by AWS or third-party vendors.
- Conditions: The specific criteria used in rules to evaluate incoming requests, such as IP addresses, HTTP headers, and request body content.

#### Handson Lab: Creating a basic AWS WAF Web ACL
1. Sign in to the AWS Management Console and open the AWS WAF console at https://console.aws.amazon.com/waf/.
2. In the navigation pane, choose "Web ACLs" and then click on the "Create web ACL" button.
3. Provide a name and description for your Web ACL, and select the appropriate region.
4. Choose the resource type to associate with the Web ACL (e.g., CloudFront distribution
, Application Load Balancer, or API Gateway).
5. Define the rules for your Web ACL by adding managed rule groups or creating custom rules based
    on your security requirements.
6. Set the default action for requests that do not match any rules (allow, block, or count).
7. Review your settings and click on the "Create web ACL" button to finalize the creation
    of your Web ACL.
8. After creating the Web ACL, monitor its performance and effectiveness using AWS WAF metrics and logs available in Amazon CloudWatch.

##### IP Set:
- An IP set is a collection of IP addresses or CIDR blocks that you can use in AWS WAF rules to allow or block requests from specific IP addresses or ranges.
#### Regex Pattern Set:
- A regex pattern set is a collection of regular expression patterns that you can use in AWS WAF rules to match specific patterns in web requests, such as URLs or headers.
##### Rule group:
- A rule group is a collection of predefined rules that you can use in AWS WAF Web ACLs to simplify the management of your security policies.

