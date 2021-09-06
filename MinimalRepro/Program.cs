using System;

using System.Net.Http;
using System.Threading.Tasks;

namespace MinimalRepro
{
    public static class Program
    {
        private const string NonExistent = "nonexistent-but-valid-domainname.wordpress.com";
        private const string Invalid = "invalid_hostname_with_underscores.wordpress.com";

        public static async Task Main()
        {
            var os = Environment.OSVersion;

            Console.WriteLine("\n\nRunning on: " + os);
            Console.WriteLine("==================================================");

            string[] addresses = { NonExistent, Invalid };

            foreach (var address in addresses)
            {
                Console.WriteLine("\n" + address);
                Console.WriteLine("****************************************");
                
                var client = new HttpClient()
                    { BaseAddress = new Uri($"https://{address}/") };

                try
                {
                    var resp = await client.GetAsync("");
                    Console.WriteLine("Response: " + resp);
                }
                catch (Exception e)
                {
                    //Console.WriteLine("Exception: " + e);
                    Console.WriteLine("Inner exception" + e?.InnerException);
                }
            }
        }
    }
}