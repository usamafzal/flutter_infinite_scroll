// ignore_for_file: file_names

// Import necessary Flutter and Dart packages.
import 'package:flutter/material.dart';
import 'package:flutter_infinite_scroll/mode.dart'; // Custom data model class.
import 'package:flutter_infinite_scroll/network.dart'; // Handles network requests.
import 'package:http/http.dart' as http; // For making HTTP requests.

// Define the HomePage widget as a stateful widget.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// State class for the HomePage widget.
class _HomePageState extends State<HomePage> {
  // List to hold the fetched posts data.
  List<Data> postsData = [];
  // List to hold the filtered data based on user input.
  List<Data> filterList = [];
  // List of categories for filtering news.
  List<String> categories = [
    "All",
    "Startups",
    "Venture",
    "Security",
    "AI",
    "Apps"
  ];
  // The currently selected category, default is "All".
  String selectedCategory = "All";
  // Current page for infinite scrolling.
  int initialPage = 1;
  // Flag to check if the last page of data has been fetched.
  bool isLastPage = false;
  // Flag to indicate if data is currently being loaded.
  bool loading = false;
  // The current search query entered by the user.
  String search = "";
  // ScrollController to listen for scroll events.
  ScrollController scrollController = ScrollController();

  // Initialize state variables and set up scroll listener.
  @override
  void initState() {
    super.initState();
    getNews(); // Fetch initial news data.
    scrollController.addListener(() {
      // Load more news when the user scrolls to the bottom.
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getNews();
      }
    });

    // Initialize filtered list with all posts.
    filterList = postsData;
  }

  // Filter the list based on search query and selected category.
  void filteredList(String searchQuery) {
    setState(() {
      // Show all posts if no search query and category is "All".
      if (searchQuery.isEmpty && selectedCategory == categories[0]) {
        filterList = postsData;
      } else {
        // Filter posts by category and search query.
        filterList = postsData
            .where(
              (element) =>
                  (selectedCategory == categories[0] ||
                      selectedCategory == element.category!) &&
                  (element.title!
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      element.category!.toLowerCase().contains(
                            searchQuery.toLowerCase(),
                          )),
            )
            .toList();
      }
    });
  }

  // Fetch news data from the API and handle pagination.
  Future<void> getNews() async {
    // Return if already loading or if all pages have been loaded.
    if (loading || isLastPage) return;
    setState(() {
      loading = true; // Set loading flag to true.
    });

    try {
      // Fetch data from the API using a network service.
      final response =
          await NetworkService.fetchNews(initialPage, http.Client());
      setState(() {
        // Update posts and pagination state.
        if (search.isEmpty && selectedCategory == categories[0]) {
          filterList = postsData;
        }
        selectedCategory == "All" && search.isEmpty
            ? {
                postsData.addAll(response.data ?? []),
                initialPage++, // Increment page number.
                isLastPage = response.data!.length < response.perPage!,
                loading = false, // Loading complete.
              }
            : loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false; // Reset loading flag on error.
      });
      // Show an error message if the widget is still mounted.
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Server Error")));
      }
    }
  }

  // Build the UI for the app.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Infinite Scroll"), // App bar title.
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0), // Add padding to the body.
          child: Column(children: [
            // Search bar widget.
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search...', // Placeholder text for search bar.
                prefixIcon: Icon(Icons.search), // Search icon.
                border: OutlineInputBorder(), // Bordered input field.
              ),
              // Update search query and filter list on text change.
              onChanged: (value) {
                setState(() {
                  search = value;
                  filteredList(search);
                });
              },
            ),
            // Horizontal list of categories.
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Scroll horizontally.
                itemCount: categories.length, // Number of categories.
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {});
                        selectedCategory =
                            categories[index]; // Update category.
                        filteredList(search); // Apply filters.
                      },
                      child: Chip(
                        label: Text(
                          categories[index], // Display category name.
                        ),
                        backgroundColor: selectedCategory == categories[index]
                            ? Colors.green // Highlight selected category.
                            : Colors.grey, // Default color for others.
                      ),
                    ),
                  );
                },
              ),
            ),
            // Main content: list of posts or loading indicator.
            Expanded(
              child: postsData.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(), // Loading indicator.
                    )
                  : filterList.isEmpty
                      ? const Center(
                          child: Text("No Text Found"), // No results message.
                        )
                      : ListView.builder(
                          controller: scrollController, // For infinite scroll.
                          itemCount: filterList.length + (loading ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show loading indicator at the end of the list.
                            if (index == filterList.length) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final data = filterList[index];

                            // Display individual post data in a card.
                            return Card(
                              child: ListTile(
                                title: Text(data.title ?? "No title"),
                              ),
                            );
                          },
                        ),
            ),
          ]),
        ));
  }

  // Clean up the scroll controller when the widget is disposed.
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
